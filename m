From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning
Date: Tue, 12 Jan 2010 11:32:45 -0500
Message-ID: <4B4CA42D.5020305@majjas.com>
References: <20100112.000804.186755338.davem@davemloft.net>
 <20100112085633.GB6628@ff.dom.local>
 <20100112.014218.112731835.davem@davemloft.net>
 <20100112.025620.210305029.davem@davemloft.net>
 <20100112081513.0175d579@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	mikem@ring3k.org, flyboy@gmail.com, rjw@sisk.pl,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta2.srv.hcvlny.cv.net ([167.206.4.197]:39637 "EHLO
	mta2.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482Ab0ALQd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 11:33:29 -0500
Received: from mail.majjas.com (ool-44c00dc8.dyn.optonline.net [68.192.13.200])
 by mta2.srv.hcvlny.cv.net
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0KW500JC17BRC9Z0@mta2.srv.hcvlny.cv.net> for
 netdev@vger.kernel.org; Tue, 12 Jan 2010 11:33:27 -0500 (EST)
In-reply-to: <20100112081513.0175d579@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2010 11:15 AM, Stephen Hemminger wrote:
> This code makes transmit path and transmit reset safer by:
>    * adding memory barrier before checking available ring slots
>    * reseting state of tx ring elements after free
>    * seperate cleanup function from ring done function
>    * removing mostly unused tx_next element
>
>
>    
Stephen,

Just want to confirm that this supersedes both of the patches I'm 
currently running with:

1. skb_may_pull
2. Nash patch
--
Mike



