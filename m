From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] ieee802154: sparse warnings: make symbols
 static
Date: Mon, 02 Jul 2012 08:44:36 +0200
Message-ID: <1341211476.5269.2.camel@edumazet-glaptop>
References: <1341209912-6030-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1341209912-6030-2-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1341211072.5269.0.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, dbaryshkov@gmail.com
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:39920 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963Ab2GBGon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 02:44:43 -0400
Received: by wibhm11 with SMTP id hm11so2831734wib.1
        for <netdev@vger.kernel.org>; Sun, 01 Jul 2012 23:44:42 -0700 (PDT)
In-Reply-To: <1341211072.5269.0.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-02 at 08:37 +0200, Eric Dumazet wrote:
> On Mon, 2012-07-02 at 10:18 +0400, Alexander Smirnov wrote:
> > Make symbols static to avoid the following warning shown up
> > by sparse:
> > 
> >     warning: symbol ... was not declared. Should it be static?
> > 
> > Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> > ---
> >  net/ieee802154/6lowpan.c |    2 +-
> >  net/mac802154/mac_cmd.c  |    2 +-
> >  net/mac802154/mib.c      |    2 +-
> >  3 files changed, 3 insertions(+), 3 deletions(-)
> > 
> > diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> > index cd5007f..17ad28f 100644
> > --- a/net/ieee802154/6lowpan.c
> > +++ b/net/ieee802154/6lowpan.c
> > @@ -124,7 +124,7 @@ struct lowpan_fragment {
> >  
> >  static unsigned short fragment_tag;
> >  static LIST_HEAD(lowpan_fragments);
> > -spinlock_t flist_lock;
> > +static spinlock_t flist_lock;
> >  
> 
> static DEFINE_SPINLOCK(flist_lock);


and of course commit 768f7c7c121e80f4 (6lowpan: add missing
spin_lock_init() ) must be reverted.
