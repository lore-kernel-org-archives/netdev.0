From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IPV6_RTHDR with a type-0 routing header
Date: Thu, 20 Aug 2009 14:39:26 +0200
Message-ID: <20090820123926.GA21858@uio.no>
References: <20090820111152.GA20295@uio.no>
 <7d4abbaea1f1e17050a0e8ffe4917cb8@chewa.net>
 <20090820121820.GA21354@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: =?utf-8?B?UsOpbWk=?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:45714 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754173AbZHTMj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 08:39:27 -0400
Content-Disposition: inline
In-Reply-To: <20090820121820.GA21354@uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2009 at 02:18:20PM +0200, Steinar H. Gunderson wrote:
> Hm, OK. And no replacement has been proposed, the deprecation RFC just refers
> to "future routing headers"...

It looks like I can use destination options instead, but those don't seem to
be too easy to use either. The kernel seems to demand that I put eight bytes
of padding at the end?

  #define ipv6_optlen(p)  (((p)->hdrlen+1) << 3)

Why the +1? 

FWIW, the program I try to run is at http://home.samfundet.no/~sesse/v6fun.c .
If I replace "len" in the setsockopt call by "len + 8", the program runs and
the packets get the right option attached -- but also eight padding bytes.
 
/* Steinar */
-- 
Homepage: http://www.sesse.net/
