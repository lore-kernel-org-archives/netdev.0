From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Wed, 30 Aug 2006 08:41:26 +0300
Message-ID: <200608300841.27202.hasso@estpak.ee>
References: <E1GIDgg-00043h-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: pb@bieringer.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from test.estpak.ee ([194.126.115.47]:1754 "EHLO devy.estpak.ee")
	by vger.kernel.org with ESMTP id S1751199AbWH3GsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 02:48:07 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1GIDgg-00043h-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Hasso Tepper <hasso@estpak.ee> wrote:
> >> You can disable it in /proc/sys/net/ipv6/conf/default/... and then
> >> reenable it on the interfaces that you actually want.
> >
> > You can't do that either (ie. reenable) in initscripts before link is
> > up.
>
> As soon as you do ifconfig ethX up it'll appear in /proc/sys and
> you can reenable it.

Only if you have addresses on it. Point is that you haven't any if 
autoconf is used (no manually configured addresses) and carrier is down 
(no cable or smth). Even link-local address is created after first 
carrier up event.

And problem isn't specific to IPv6, there is same problem with IPv4. For 
example if carrier aware network configuration method is used (as 
nowadays common Networkmanager is).

regards,

-- 
Hasso Tepper
