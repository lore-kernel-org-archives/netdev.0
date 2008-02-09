From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] libertas: Don't mark exported symbols as static
Date: Sat, 09 Feb 2008 08:52:35 -0500
Message-ID: <1202565155.15334.0.camel@localhost.localdomain>
References: <adatzkj0z7l.fsf@cisco.com> <20080208162824.461451e1@extreme>
	 <adaejbm28ip.fsf@cisco.com>  <20080209044858.GA1428@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56592 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754772AbYBINzY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Feb 2008 08:55:24 -0500
In-Reply-To: <20080209044858.GA1428@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-02-08 at 23:48 -0500, Christoph Hellwig wrote:
> On Fri, Feb 08, 2008 at 06:01:02PM -0800, Roland Dreier wrote:
> >  > Why not pull the exports? they aren't used anywhere in the existing kernel.
> > 
> > I'm guessing there's some not-(yet-)merged mesh networking stuff that
> > uses the symbols, but it doesn't matter much to me...
> 
> The general rule is to not keep symbols for out of tree stuff, so
> removing the exports makes more sense.

If they aren't used in the in-kernel driver, just kill the export
statements.

Dan

