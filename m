From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] libertas: Don't mark exported symbols as static
Date: Fri, 8 Feb 2008 23:48:58 -0500
Message-ID: <20080209044858.GA1428@infradead.org>
References: <adatzkj0z7l.fsf@cisco.com> <20080208162824.461451e1@extreme> <adaejbm28ip.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:54690 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604AbYBIEt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 23:49:27 -0500
Content-Disposition: inline
In-Reply-To: <adaejbm28ip.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 08, 2008 at 06:01:02PM -0800, Roland Dreier wrote:
>  > Why not pull the exports? they aren't used anywhere in the existing kernel.
> 
> I'm guessing there's some not-(yet-)merged mesh networking stuff that
> uses the symbols, but it doesn't matter much to me...

The general rule is to not keep symbols for out of tree stuff, so
removing the exports makes more sense.

