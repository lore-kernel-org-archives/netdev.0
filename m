From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net v2] flow_dissector: Check skb for VLAN only if skb
 specified.
Date: Wed, 19 Oct 2016 10:00:36 -0400
Message-ID: <20161019140035.GA2588@roberto>
References: <1476736212-21238-1-git-send-email-e@erig.me>
 <CAJ3xEMiR3EODEV5aQ9cQG=7YZtVfFkbpHn79_j+s8H7XQ5F0rA@mail.gmail.com>
 <CAPcc5Pg=vy67dMcr4U6DFwZu5UgSWyV6c662cv9XR-QXKfUVXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: amir@vadai.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:35253 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750747AbcJSOJr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:09:47 -0400
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 534DB486305
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 16:00:50 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <CAPcc5Pg=vy67dMcr4U6DFwZu5UgSWyV6c662cv9XR-QXKfUVXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2016 at 11:44:10AM +0300, Amir Vadai wrote:
> On Tue, Oct 18, 2016 at 4:59 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> > On Mon, Oct 17, 2016 at 11:30 PM, Eric Garver <e@erig.me> wrote:
> >> Fixes a panic when calling eth_get_headlen(). Noticed on i40e driver.
> >>
> >> Fixes: d5709f7ab776 ("flow_dissector: For stripped vlan, get vlan info from skb->vlan_tci")
> >> Signed-off-by: Eric Garver <e@erig.me>
> >
> > Dave,
> >
> > Hadar is OOO and I have asked Amir to look on the fix, will appreciate
> > if we can have 24 hours to respond
> >
> > Or.
> 
> Reviewed and tested.
> 
> Acked-by: Amir Vadai <amir@vadai.me>

Amir,

Your ACK may have been lost on its way to the list. I received it, but
it's not showing on any list archives or patchwork.
