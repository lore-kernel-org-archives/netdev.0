From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [TCP bug, regression] stuck distcc connections in latest -git
Date: Thu, 24 Jul 2008 12:36:44 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807241233130.24801@wrl-59.cs.helsinki.fi>
References: <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, w@1wt.eu, davem@davemloft.net,
	davidn@davidnewall.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49881 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbYGXJgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 05:36:46 -0400
In-Reply-To: <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jul 2008, Herbert Xu wrote:

> Ingo Molnar <mingo@elte.hu> wrote:
> >
> > the client (running 2.6.24) does periodic 120 seconds retransmits:
> > 
> > 07:40:48.255452 IP dione.39201 > phoenix.distcc: . 1608:2144(536) ack 1 win 584007:40:48.255547 IP phoenix.distcc > dione.39201: . ack 2144 win 65535
> > 07:40:48.255564 IP dione.39201 > phoenix.distcc: . 67143:67679(536) ack 1 win 5840
> > 07:40:48.255648 IP phoenix.distcc > dione.39201: . ack 2144 win 65535
> > 07:42:48.255440 IP dione.39201 > phoenix.distcc: . 2144:2680(536) ack 1 win 5840
> > 07:42:48.255559 IP phoenix.distcc > dione.39201: . ack 2680 win 65535
> > 07:42:48.255570 IP dione.39201 > phoenix.distcc: . 67679:68215(536) ack 1 win 5840
> > 07:42:48.255659 IP phoenix.distcc > dione.39201: . ack 2680 win 65535
> > 07:44:48.255436 IP dione.39201 > phoenix.distcc: . 2680:3216(536) ack 1 win 584007:44:48.255570 IP phoenix.distcc > dione.39201: . ack 3216 win 65535
> > 07:44:48.255585 IP dione.39201 > phoenix.distcc: . 68215:68751(536) ack 1 win 5840
> > 07:44:48.255669 IP phoenix.distcc > dione.39201: . ack 3216 win 65535
>
> OK, something's seriously screwed up on dione's kernel.  Could
> you please disable syncookies (which should enable SACK for you)
> and see if the problem goes away?

This looks like the FRTO bugs we fixed in 2.6.25.7, afaik, 2.6.24.y wasn't 
anymore updated at that time so it's a bit obsolete...


-- 
 i.
