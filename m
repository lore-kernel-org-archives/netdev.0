From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 6/7] slub: improve bulk alloc strategy
Date: Wed, 17 Jun 2015 08:29:05 +0200
Message-ID: <20150617082905.54fc0094@redhat.com>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155246.18824.3788.stgit@devil>
	<20150616145336.1cacbfb88ff55b0e088676c3@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>,
	netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>, brouer@redhat.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45557 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754882AbbFQG3K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 02:29:10 -0400
In-Reply-To: <20150616145336.1cacbfb88ff55b0e088676c3@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Jun 2015 14:53:36 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 15 Jun 2015 17:52:46 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
[...]
> > +			/* Invoke slow path one time, then retry fastpath
> > +			 * as side-effect have updated c->freelist
> > +			 */
> 
> That isn't very grammatical.
> 
> Block comments are formatted
> 
> 	/*
> 	 * like this
> 	 */
> 
> please.

Sure, old habit, this comment style is just that we use in net/ tree.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
