From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: Request to include ESFQ patch
Date: Sun, 06 Jan 2008 20:01:40 +0000
Message-ID: <478133A4.4020903@andyfurniss.entadsl.com>
References: <20080102155903.M66678@visp.net.lb>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugfood-c@fatooh.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:47818 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752704AbYAFUdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2008 15:33:51 -0500
In-Reply-To: <20080102155903.M66678@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> Hi
> 
> I took risk and installed ESFQ on my main backbone QoS. I found it highly 
> useful, and very need in setup's where is more than 128 flows passing and 
> especially where is nat available.

I agree it will be good when it's in.

> 
> Here is results with overloaded class for low-priority P2P traffic customers:
> 

*sfq was never meant for interactive traffic as such. If you really want 
to do QOS for them you would need to (somehow) classify interactive and 
give it prio over bulk. I know this may not be practical for your setup, 
but what ping times users get will vary depending how many other active 
users there are/queue length/how many tcps the user has open etc.

Andy.
