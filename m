From: Jens Rosenboom <jens@mcbone.net>
Subject: Re: IPV6_RTHDR with a type-0 routing header
Date: Thu, 20 Aug 2009 14:53:44 +0200
Message-ID: <1250772824.9489.3.camel@fnki-nb00130>
References: <20090820111152.GA20295@uio.no>
	 <7d4abbaea1f1e17050a0e8ffe4917cb8@chewa.net>
	 <20090820121820.GA21354@uio.no>  <20090820123926.GA21858@uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>,
	netdev@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:45054 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754197AbZHTMxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 08:53:52 -0400
In-Reply-To: <20090820123926.GA21858@uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-20 at 14:39 +0200, Steinar H. Gunderson wrote:
> On Thu, Aug 20, 2009 at 02:18:20PM +0200, Steinar H. Gunderson wrote:
> > Hm, OK. And no replacement has been proposed, the deprecation RFC just refers
> > to "future routing headers"...
> 
> It looks like I can use destination options instead, but those don't seem to
> be too easy to use either. The kernel seems to demand that I put eight bytes
> of padding at the end?
> 
>   #define ipv6_optlen(p)  (((p)->hdrlen+1) << 3)
> 
> Why the +1? 

Because that matches the definition of the hdrlen field in RFC2460.

> FWIW, the program I try to run is at http://home.samfundet.no/~sesse/v6fun.c .
> If I replace "len" in the setsockopt call by "len + 8", the program runs and
> the packets get the right option attached -- but also eight padding bytes.

ERROR 404: Not Found.

