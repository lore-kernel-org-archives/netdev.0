From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH bug-fix] iproute: fix documentation for ip rule scan order
Date: Thu, 8 Sep 2016 11:59:55 +0200
Message-ID: <20160908095955.GA10034@unicorn.suse.cz>
References: <CAN04xNR8SH4D57mfY0nVDSNWvZfaaOLci2yB0-8nKg=Hv9SEbw@mail.gmail.com>
 <20160901090454.657f0b73@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Iskren Chernev <iskren@imo.im>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38436 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965916AbcIHJ76 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 05:59:58 -0400
Content-Disposition: inline
In-Reply-To: <20160901090454.657f0b73@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 01, 2016 at 09:04:54AM -0700, Stephen Hemminger wrote:
> On Tue, 30 Aug 2016 17:32:52 -0700
> Iskren Chernev <iskren@imo.im> wrote:
> 
> > From 416f45b62f33017d19a9b14e7b0179807c993cbe Mon Sep 17 00:00:00 2001
> > From: Iskren Chernev <iskren@imo.im>
> > Date: Tue, 30 Aug 2016 17:08:54 -0700
> > Subject: [PATCH bug-fix] iproute: fix documentation for ip rule scan order
> > 
> > ---
> >  man/man8/ip-rule.8 | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
> > index 1774ae3..3508d80 100644
> > --- a/man/man8/ip-rule.8
> > +++ b/man/man8/ip-rule.8
> > @@ -93,7 +93,7 @@ Each policy routing rule consists of a
> >  .B selector
> >  and an
> >  .B action predicate.
> > -The RPDB is scanned in order of decreasing priority. The selector
> > +The RPDB is scanned in order of increasing priority. The selector
> >  of each rule is applied to {source address, destination address,
> > incoming
> >  interface, tos, fwmark} and, if the selector matches the packet,
> >  the action is performed. The action predicate may return with success.
> > --
> > 2.4.5
> 
> Applied

I'm sorry I didn't notice before but this just reverts the change done
by commit 49572501664d ("iproute2: clarification of various man8 pages").
IMHO the problem is that both versions are equally confusing as the word
"priority" can be understood in two different senses.

How about more explicit formulation, e.g.

  ... in order of decreasing logical priority (i.e. increasing numeric
  values).

Would that be better?

Michal Kubecek
