From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [RFC 0/2] netfilter: xtables: CONDITION target implementation
Date: Mon, 19 Jul 2010 17:31:49 +0300
Message-ID: <1279549909.7097.39.camel@powerslave>
References: <1279548947-10470-1-git-send-email-luciano.coelho@nokia.com>
	 <AANLkTilRtCiuAwox2sTsEu73fE89OLEUtIbVQ_njtkqz@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>
To: ext Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:40058 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933554Ab0GSOcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 10:32:10 -0400
In-Reply-To: <AANLkTilRtCiuAwox2sTsEu73fE89OLEUtIbVQ_njtkqz@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-07-19 at 16:27 +0200, ext Changli Gao wrote:
> On Mon, Jul 19, 2010 at 10:15 PM, Luciano Coelho
> <luciano.coelho@nokia.com> wrote:
> > From: Luciano Coelho <coelho@testbed.(none)>
> >
> > Hi all,
> >
> > As discussed earlier, I've been looking for a way to enable and disable the
> > condition match automatically, in the netfilter tables themselves (ie. without
> > the need to use procfs).
> >
> > This is my initial implementation.  Please let me know how it looks.  The first
> > patch is based on the xt_condition patch that Jan sent to the list (but which
> > has not been finalized for inclusion yet).  Once the condition match gets
> > applied, I'll forward port my patch and submit it again.
> >
> > Cheers,
> > Luca.
> >
> > Luciano Coelho (2):
> >  netfilter: xt_condition: export list management code
> >  netfilter: xtables: implement CONDITION target
> >
> >  include/linux/netfilter/Kbuild         |    1 +
> >  include/linux/netfilter/xt_CONDITION.h |   39 +++++++++++
> >  include/linux/netfilter/xt_condition.h |   17 +++++-
> >  net/netfilter/Kconfig                  |   12 ++++
> >  net/netfilter/Makefile                 |    1 +
> >  net/netfilter/xt_CONDITION.c           |  112 ++++++++++++++++++++++++++++++++
> >  net/netfilter/xt_condition.c           |   82 ++++++++++++++----------
> 
> Why not combine xt_CONDITION.c and xt_condition.c into xt_condition.c,
> like xt_mark.c?

I just thought that someone may want to use the condition match without
using the CONDITION target, that's why I've put it in a different
module.

But I don't have a strong opinion about this.  If everybody agrees on
that, I can merge the code into a single module.

Thanks for your comment.

-- 
Cheers,
Luca.

