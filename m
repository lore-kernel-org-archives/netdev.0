From: Martin Schwenke <martin@meltin.net>
Subject: Re: [PATCH] ip monitor: Enable prefix labels when monitoring more
 than 1 object
Date: Fri, 16 Aug 2013 16:52:13 +1000
Message-ID: <20130816165213.68c2ea6c@martins.ozlabs.org>
References: <20130815070527.1df23bea@martins.ozlabs.org>
	<20130815234047.0018f3dd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44659 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750902Ab3HPGwT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Aug 2013 02:52:19 -0400
In-Reply-To: <20130815234047.0018f3dd@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Aug 2013 23:40:47 -0700, Stephen Hemminger
<stephen@networkplumber.org> wrote:

> On Thu, 15 Aug 2013 07:05:27 +1000
> Martin Schwenke <martin@meltin.net> wrote:
> 
> > Prefix labelling is currently only activated when monitoring "all"
> > objects.  However, the output can still be confusing when monitoring
> > more than 1 object, so enable prefix labels in this case.
> > 
> > Signed-off-by: Martin Schwenke <martin@meltin.net>
> 
> I understand where you are coming from, but changing the output format
> might break people with scripts doing parsing the current format.
> 
> Since there is already a flag to ip monitor to put on prefix labels,
> why not just use that if you need to?

Sorry, I can't see that option in either the usage message or in the
code.  In the current code the only place I can see prefix_banner
being set is in the "all" case.  I think "prefix" is about monitoring
IPv6 prefixes or similar.

Perhaps I could add a "label" option instead?

> This seems like a change likely to upset more people than it pleases.

Yeah, perhaps...  :-(

peace & happiness,
martin
