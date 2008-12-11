From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Default offload settings in Ethernet drivers
Date: Thu, 11 Dec 2008 10:54:59 -0800
Message-ID: <20081211105459.3e615be8@s6510>
References: <49415EDB.3030006@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57101 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755082AbYLKSzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2008 13:55:08 -0500
In-Reply-To: <49415EDB.3030006@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Dec 2008 19:41:31 +0100
Jan Ceuleers <jan.ceuleers@computer.org> wrote:

> Hi!
> 
> A discussion recently took place on the power mailing list on the 
> subject of the impact of (hardware-assisted) offload functions on the 
> power efficiency of the overall system.
> 
> The discussion was brought on by me noticing that not all drivers enable 
>   all of their offload features by default (case in point: r8169).
> 
> Although the discussion may not be complete, early indications are that:
> 
> 1. Hardware-assisted offloads improve power efficiency unless 
> implemented in a separate CPU (TOE / Total Offloading);
> 
> 2. It would probably be a good idea to enable hardware-assisted offloads 
> other than TOE by default given the above.
> 
> I would therefore like to sollicit views here:
> 
> 1. Would changing default offload settings in Ethernet drivers help to 
> save the planet?
> 
> 2. Which offload settings does it make sense to enable by default?

Go get a kill-a-watt meter and real hardware and measure.
I don't think there will be any difference. Linux (mainline) doesn't
do TOE. It does do segmentation offload, and any driver that can
do segmentation offload enables it by default.
