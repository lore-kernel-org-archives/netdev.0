From: Ben Greear <greearb@candelatech.com>
Subject: Re: ixgbe:  schedule while atomic bug during dev_disable_lro  2.6.31-rc3
Date: Thu, 16 Jul 2009 14:08:58 -0700
Message-ID: <4A5F96EA.9010008@candelatech.com>
References: <4A5E5F8A.308@candelatech.com> <Pine.WNT.4.64.0907161206260.5316@ppwaskie-MOBL2.amr.corp.intel.com> <4A5F8062.6090009@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51150 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932899AbZGPVI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 17:08:59 -0400
In-Reply-To: <4A5F8062.6090009@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/2009 12:32 PM, Ben Greear wrote:

> It is 100% reproducible on the system I'm testing. I haven't tried other
> servers
> or other ixgbe NICs yet.
>
> I'll try w/out pre-empt, should have results later today.

I set pre-empt to Voluntary and I no longer see these warnings
in dmesg.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

