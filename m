From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Why my NIC shows NUMA -1?
Date: Wed, 11 Nov 2015 15:25:41 -0800
Message-ID: <5643CE75.3060709@gmail.com>
References: <CAK3+h2wTdCVHLpwoKF93aGeKd2MTtgMK2cNstw94a=Fv_94iGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Vincent Li <vincent.mc.li@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34231 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899AbbKKXZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 18:25:42 -0500
Received: by padhx2 with SMTP id hx2so44465451pad.1
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 15:25:42 -0800 (PST)
In-Reply-To: <CAK3+h2wTdCVHLpwoKF93aGeKd2MTtgMK2cNstw94a=Fv_94iGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/2015 02:41 PM, Vincent Li wrote:
> Hi
>
> Sorry I am not sure if this is the right list to ask this question,
> please direct me to the correct one. thanks!
>
> I am using Intel 82599 on Dell PowerEdge R710 which should support
> NUMA node, the box is running ubuntu 14.01.1 LTS , I am wondering why I
> get NUMA socket -1.

The PowerEdge R710 is an older Nehalem based Intel system isn't it? 
Those didn't have the PCIe controller built into the socket.  As such 
what you may have is both sockets hanging off of one I/O Hub and if that 
is the case the PCIe device is the same distance from either socket.  In 
that case it would be correct for it to report -1 since either socket is 
the same distance.

- Alex
