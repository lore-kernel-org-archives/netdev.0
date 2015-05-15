From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink: Kill bogus lock_sock in netlink_insert
Date: Fri, 15 May 2015 11:01:54 -0700
Message-ID: <1431712914.27831.116.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150514042151.GA5482@gondor.apana.org.au>
	 <20150514055824.GB6058@gondor.apana.org.au>
	 <20150514060230.GD6058@gondor.apana.org.au>
	 <20150515.124955.1765730151919172866.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, netdev@vger.kernel.org,
	ying.xue@windriver.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:35747 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933041AbbEOSB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 14:01:56 -0400
Received: by igbyr2 with SMTP id yr2so230740756igb.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 11:01:55 -0700 (PDT)
In-Reply-To: <20150515.124955.1765730151919172866.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-15 at 12:49 -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 14 May 2015 14:02:30 +0800
> 
> > On Thu, May 14, 2015 at 01:58:24PM +0800, Herbert Xu wrote:
> >> 
> >> This patch also removes a bogus socket lock introduced by that
> >> very same patch.
> > 
> > This bogus socket lock is still there in the current tree.
> > 
> > ---8<---
> > The commit c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink:
> > eliminate nl_sk_hash_lock") added a lock_sock to netlink_insert
> > with no justifications whatsoever.
> > 
> > This patch kills it.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Eric, does this improve your benchmark?

I don't think so, but I can test this in about one hour.
