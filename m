From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 2/2] r8152: rx descriptor check
Date: Sat, 12 Nov 2016 08:21:24 -0500
Message-ID: <17ddc468-3099-a423-422c-d0ae33489288@pobox.com>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-228-Taiwan-albertk@realtek.com>
 <20161111121311.GA19673@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>,
        Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pb-sasl1.pobox.com ([64.147.108.66]:57006 "EHLO
        sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938767AbcKLNV3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2016 08:21:29 -0500
In-Reply-To: <20161111121311.GA19673@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-11 07:13 AM, Francois Romieu wrote:
> Hayes Wang <hayeswang@realtek.com> :
>> For some platforms, the data in memory is not the same with the one
>> from the device. That is, the data of memory is unbelievable. The
>> check is used to find out this situation.
> 
> Invalid packet size corrupted receive descriptors in Realtek's device
> reminds of CVE-2009-4537.
> 
> Is the silicium of both devices different enough to prevent the same
> exploit to happen ?

I don't know if the hardware can do it, but the existing Linux device
driver regularly attempts to process huge unreal packet sizes here.
I've had to patch it to reject "packets" larger than the configured MRU.
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
