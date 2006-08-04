From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Fri, 04 Aug 2006 06:45:26 -0400
Message-ID: <1154688326.5187.53.camel@jzny2>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
	 <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
	 <1154628302.3117.15.camel@rh4> <1154642918.5187.13.camel@jzny2>
	 <1154650197.3117.32.camel@rh4> <20060804011027.GC12085@gondor.apana.org.au>
	 <20060804083734.GA16082@gondor.apana.org.au>
	 <20060804101017.GA17393@gondor.apana.org.au>
	 <1154686563.5187.43.camel@jzny2>
	 <20060804102557.GA17723@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:65214 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1161146AbWHDKpb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 06:45:31 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G8xBM-000827-MM
	for netdev@vger.kernel.org; Fri, 04 Aug 2006 06:45:32 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060804102557.GA17723@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-08 at 20:25 +1000, Herbert Xu wrote:

> Well it's not that good since the current code only takes the
> lock in exceptional circumstances while my patch does the atomic
> op unconditionally.

yes, it would be nice to fix that. However, from a selfish angle, my
worries are more about the overload case ;-> logically it is more likely
you have a lot less CPU resources when overloaded than in the common
case; actually now i have said "common" 100 times i understand Jesse
better ;->. 
 
> But then again the current code is wrong :)

indeed.

cheers,
jamal

