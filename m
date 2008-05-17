From: "Chris Peterson" <cpeterso@cpeterso.com>
Subject: Re: [PATCH] Re: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Sat, 17 May 2008 12:54:02 -0700
Message-ID: <a24804730805171254i2a37da61mb47280db7b330ed5@mail.gmail.com>
References: <20080515142154.0595e475@core> <482C7DA3.1090809@garzik.org>
	 <482C953A.4080205@garzik.org> <87abirytxj.fsf@basil.nowhere.org>
	 <20080516105635.6cb1f505@core> <482D5FC5.2070103@firstfloor.org>
	 <20080516121239.GA9627@gondor.apana.org.au>
	 <482DB568.1040704@firstfloor.org>
	 <20080517010136.GA15102@gondor.apana.org.au>
	 <482EBAA8.3040506@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Jeff Garzik" <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	tpmdd-devel@lists.sourceforge.net, tpm@selhorst.net
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:8917 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbYEQTyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 15:54:03 -0400
Received: by wa-out-1112.google.com with SMTP id j37so971771waf.23
        for <netdev@vger.kernel.org>; Sat, 17 May 2008 12:54:02 -0700 (PDT)
In-Reply-To: <482EBAA8.3040506@firstfloor.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Would people be ok with kernel auto-feeding for /dev/urandom only? I've
> been pondering that and I think that would work just as well in practice
>  given the facts above. Then you would still only get blocking
> /dev/random with the user daemon, but that won't matter because all
> the usual users don't rely on thatanyways.

Andi, can you please clarify what you mean by "auto-feeding
/dev/urandom only" and "only get blocking /dev/random with the user
daemon"? Are you suggesting that the kernel provides /dev/urandom and
a userspace daemon (e.g. EGD) provides /dev/random?

Also, if crypto apps like ssh and openssl use on "insecure"
/dev/urandom, then who actually relies on /dev/random? For comparison,
FreeBSD does not even (AFAIK) have /dev/urandom. FreeBSD's /dev/random
is nonblocking (like Linux's /dev/urandom) and includes network
entropy.


chris
