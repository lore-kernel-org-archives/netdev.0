From: jamal <hadi@cyberus.ca>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Thu, 25 May 2006 11:38:30 -0400
Message-ID: <1148571510.5283.33.camel@jzny2>
References: <44731733.7000204@ti-wmc.nl>
	 <20060523094324.11926fcc@localhost.localdomain>
	 <447349A6.50105@fastmail.fm> <1148496189.5325.33.camel@jzny2>
	 <44758CA8.2030502@fastmail.fm>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herman.elfrink@ti-wmc.nl, Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:37564 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1030227AbWEYPid
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 11:38:33 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FjHv2-0005SR-L0
	for netdev@vger.kernel.org; Thu, 25 May 2006 11:38:36 -0400
To: Simon Oosthoek <wmc_simon@fastmail.fm>
In-Reply-To: <44758CA8.2030502@fastmail.fm>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-25-05 at 12:53 +0200, Simon Oosthoek wrote:

> 
> I agree with your analysis, and recently I read an interesting interview 
> with her (I think it was linked from slashdot, an interview with the 
> "mother of the Internet ;-) I'm not sure her work (I don't exactly 
> recall the specifics) is applicable to our problem though.
> 

Look at her effort ion rbridges, i think youll find theres a lot in
common.

> Regarding the scalability, I think it rather depends on the number of 
> hops how usable FLAME is. I don't think it would scale well to a campus 
> or city wide network, but in the case of a few mobile nodes, it has very 
> little overhead both in bandwidth and delay.

You should mention this limitation in the paper.   
BTW, something else: You ability to create loops of broadcast storms is
highly probable. Eventually you may have to go to L3 (TTL is of value
there) ;->


cheers,
jamal


