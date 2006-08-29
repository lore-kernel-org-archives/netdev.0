From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 16:59:49 +0300
Message-ID: <200608291659.49876.hasso@estpak.ee>
References: <E1GI3Gz-0002vW-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Peter Bieringer <pb@bieringer.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from test.estpak.ee ([194.126.115.47]:3830 "EHLO devy.estpak.ee")
	by vger.kernel.org with ESMTP id S964978AbWH2N7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 09:59:52 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1GI3Gz-0002vW-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Peter Bieringer <pb@bieringer.de> wrote:
> > BTW: this is also the reason why autoconf or accept_ra cannot be
> > disabled by e.g. initscripts *per* interface before bringing one up.
>
> You can disable it in /proc/sys/net/ipv6/conf/default/... and then
> reenable it on the interfaces that you actually want.

You can't do that either (ie. reenable) in initscripts before link is up.


regards,

-- 
Hasso

