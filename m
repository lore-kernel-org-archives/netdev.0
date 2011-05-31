From: WeipingPan <panweiping3@gmail.com>
Subject: Re: netxen_nic: unregister_netdevice error
Date: Tue, 31 May 2011 17:21:30 +0800
Message-ID: <4DE4B31A.3090201@gmail.com>
References: <4DE4877C.1070704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:52175 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756233Ab1EaJUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 05:20:52 -0400
Received: by qyg14 with SMTP id 14so2287741qyg.19
        for <netdev@vger.kernel.org>; Tue, 31 May 2011 02:20:51 -0700 (PDT)
In-Reply-To: <4DE4877C.1070704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/31/2011 02:15 PM, WeipingPan wrote:
> hi,
>
> When test bonding broadcast mode I met a problem.
> modprobe -r bonding will fail after I ping broadcast address.
>
> I find that the problem only shows up when I use netxen_nic driver.
> When use ixgbe and bn2x2 driver, no problem occurs.
>
> I use RHEL 6.2, kernel 2.6.32-131.0.15.el6.i686,
> Can anybody confirm this bug using 2.6.39 or upstream ?
>
> many thanks
> Weiping Pan
>
I got a machine to test the 
upstream,55922c9d1b84b89cb946c777fddccb3247e7df2c
the problem disappears.

many thanks
Weiping Pan

