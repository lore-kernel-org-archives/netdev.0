From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IPV6_RTHDR with a type-0 routing header
Date: Thu, 20 Aug 2009 15:11:54 +0200
Message-ID: <20090820131154.GA22460@uio.no>
References: <20090820111152.GA20295@uio.no>
 <7d4abbaea1f1e17050a0e8ffe4917cb8@chewa.net>
 <20090820121820.GA21354@uio.no>
 <20090820123926.GA21858@uio.no>
 <1250772824.9489.3.camel@fnki-nb00130>
 <20090820130009.GA22183@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: =?utf-8?B?UsOpbWk=?= Denis-Courmont <remi@remlab.net>,
	netdev@vger.kernel.org
To: Jens Rosenboom <jens@mcbone.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:54260 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753765AbZHTNLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 09:11:55 -0400
Content-Disposition: inline
In-Reply-To: <20090820130009.GA22183@uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2009 at 03:00:09PM +0200, Steinar H. Gunderson wrote:
>> Because that matches the definition of the hdrlen field in RFC2460.
> Hm, in that case I guess it's glibc that has one too much indeed (I never
> write this field).

Yes indeed. It's fixed in more recent glibc:

   [BZ #5760]
   * inet/inet6_opt.c (inet6_opt_init): Fix ip6h_len computation.
   Patch by Roland Bless <roland@bless.de>.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
