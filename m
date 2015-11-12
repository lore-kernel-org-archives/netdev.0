From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: Why my NIC shows NUMA -1?
Date: Wed, 11 Nov 2015 16:21:46 -0800
Message-ID: <CAK3+h2w_neDt9rX5e90Sn8np993_XjPSDWy+YgnrDUhQcE+uuA@mail.gmail.com>
References: <CAK3+h2wTdCVHLpwoKF93aGeKd2MTtgMK2cNstw94a=Fv_94iGQ@mail.gmail.com>
	<5643CE75.3060709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:34375 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbbKLAVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 19:21:47 -0500
Received: by lbvs9 with SMTP id s9so2524016lbv.1
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 16:21:46 -0800 (PST)
In-Reply-To: <5643CE75.3060709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes PowerEdge R710 is Nehalem based Intel system. thank you for the answer

On Wed, Nov 11, 2015 at 3:25 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On 11/11/2015 02:41 PM, Vincent Li wrote:
>>
>> Hi
>>
>> Sorry I am not sure if this is the right list to ask this question,
>> please direct me to the correct one. thanks!
>>
>> I am using Intel 82599 on Dell PowerEdge R710 which should support
>> NUMA node, the box is running ubuntu 14.01.1 LTS , I am wondering why I
>> get NUMA socket -1.
>
>
> The PowerEdge R710 is an older Nehalem based Intel system isn't it? Those
> didn't have the PCIe controller built into the socket.  As such what you may
> have is both sockets hanging off of one I/O Hub and if that is the case the
> PCIe device is the same distance from either socket.  In that case it would
> be correct for it to report -1 since either socket is the same distance.
>
> - Alex
