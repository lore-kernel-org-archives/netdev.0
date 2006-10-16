From: Per Liden <per.liden@ericsson.com>
Subject: Re: [PATCH 9/14] [TIPC] Name publication events now delivered in
 chronological order
Date: Mon, 16 Oct 2006 10:50:40 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0610161046160.17974@ulinpc219.uab.ericsson.se>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
 <1160739475953-git-send-email-per.liden@ericsson.com>
 <20061013191337.cdee991b.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:63469 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1161224AbWJPIuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 04:50:44 -0400
To: Bill Fink <billfink@mindspring.com>
In-Reply-To: <20061013191337.cdee991b.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm fairly sure this is a problem on your side. I received patch 10/14 
from the netdev list and the two list archives I checked also had it.

/Per

On Fri, 13 Oct 2006, Bill Fink wrote:

> FYI,
> 
> At least here, I received two copies of patch 9/14 and no copy
> of patch 10/14.
> 
> 						-Bill
> 
> 
> 
> On Fri, 13 Oct 2006 13:37:50 +0200, Per Liden wrote:
> 
> > From: Allan Stephens <allan.stephens@windriver.com>
> > 
> > This patch tivially re-orders the entries in TIPC's list of local
> > publications so that applications will receive publication events
> > in the order they were published.
> > 
> > Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> > Signed-off-by: Per Liden <per.liden@ericsson.com>
> > ---
> >  net/tipc/name_distr.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
> > index f0b063b..03bd659 100644
> > --- a/net/tipc/name_distr.c
> > +++ b/net/tipc/name_distr.c
> > @@ -122,7 +122,7 @@ void tipc_named_publish(struct publicati
> >  	struct sk_buff *buf;
> >  	struct distr_item *item;
> >  
> > -	list_add(&publ->local_list, &publ_root);
> > +	list_add_tail(&publ->local_list, &publ_root);
> >  	publ_cnt++;
> >  
> >  	buf = named_prepare_buf(PUBLICATION, ITEM_SIZE, 0);
> > -- 
> > 1.4.1
> 
