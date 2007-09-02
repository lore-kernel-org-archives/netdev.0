From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [1/1] Block device throttling [Re: Distributed storage.]
Date: Sat, 1 Sep 2007 21:42:53 -0700
Message-ID: <200709012142.55534.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708301620.37965.phillips@phunq.net> <20070831214137.GD30122@agk.fab.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Neil Brown <neilb@suse.de>
To: Alasdair G Kergon <agk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from phunq.net ([64.81.85.152]:60818 "EHLO moonbase.phunq.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750749AbXIBEnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Sep 2007 00:43:17 -0400
In-Reply-To: <20070831214137.GD30122@agk.fab.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 31 August 2007 14:41, Alasdair G Kergon wrote:
> On Thu, Aug 30, 2007 at 04:20:35PM -0700, Daniel Phillips wrote:
> > Resubmitting a bio or submitting a dependent bio from
> > inside a block driver does not need to be throttled because all
> > resources required to guarantee completion must have been obtained
> > _before_ the bio was allowed to proceed into the block layer.
>
> I'm toying with the idea of keeping track of the maximum device stack
> depth for each stacked device, and only permitting it to increase in
> controlled circumstances.

Hi Alasdair,

What kind of circumstances did you have in mind?

Regards,

Daniel
