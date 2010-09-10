From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: empty ack packets
Date: Thu, 9 Sep 2010 22:29:15 -0700
Message-ID: <35088ECA-4FBF-47E9-8590-022B45A7F33D@earthlink.net>
References: <AANLkTimkvDsqY==1JQRhH54+P7yAzFX4omYN0r9+_mi=@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: MK <stardust496@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:45840 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750936Ab0IJF31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 01:29:27 -0400
In-Reply-To: <AANLkTimkvDsqY==1JQRhH54+P7yAzFX4omYN0r9+_mi=@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MK,


	The 1st packet is probably generating window update information.

	If the TCP flow is in slow start, it should not be doing any delacks
	to keep as many normal acks in the flow.

	Mitchell Erblich

	
On Sep 9, 2010, at 10:12 PM, MK wrote:

> Hello list,
> 
> I am looking at a tcpdump and I see that very very frequently, after
> receiving a segment, my tcp is sending an empty ack back in a matter
> of several (around 20 - 50) microseconds. And then after several more
> microseconds, my tcp is sending some valid outgoing data. I am trying
> to understand why it decided to send an empty ack back when that ack
> could potentially have been delayed by microseconds and get
> piggybacked on the outgoing data.
> 
> From the code, it appears that the delayed ack timeout is 40 millisecs
> so it is likely not the delack timer that is causing this. (And I do
> not have the quickack option)
> 
> This is RHEL5 (2.6.18) kernel.
> 
> Does anybody have an idea as to what is happening?
> 
> Thanks a lot!!
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

