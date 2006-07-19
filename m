From: Jouni Malinen <jkm@devicescape.com>
Subject: Re: michael_mic in crypto api?
Date: Wed, 19 Jul 2006 09:19:13 -0700
Message-ID: <20060719161913.GA15317@instant802.com>
References: <200607152144.44350.flamingice@sourmilk.net> <E1G3E8f-0007xk-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wu <flamingice@sourmilk.net>, jbenc@suse.cz,
	linville@tuxdriver.com, netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-21.dex002.intermedia.net ([64.78.21.92]:45898 "EHLO
	dhost002-21.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1030199AbWGSQXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 12:23:43 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1G3E8f-0007xk-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 20, 2006 at 01:39:05AM +1000, Herbert Xu wrote:
> Michael Wu <flamingice@sourmilk.net> wrote:
> > Simplicity and consistency. Whereas the relatively simple mic part of the TKIP 
> > algorithm is in crypto API, the (more important, more complicated) key mixing 
> > part is not in crypto api.

> Sure, I don't mind either way.  I think Jouni wrote this originally,
> maybe he can share his thoughts with us?

I was more or less told that TKIP implementation cannot be included in
the kernel tree before this was moved into crypto api.. I don't really
care much where it is, but since it is now in crypto api, it would sound
easiest to just keep it there. If someone really wants to move it away
from there and into TKIP code in ieee80211/d80211, feel free to do that.
However, at least for some time, there are two different TKIP
implementations (net/ieee80211 and net/d80211) so this would mean
duplicating Michael MIC implementation and I would rather not do that.

-- 
Jouni Malinen                                            PGP id EFC895FA
