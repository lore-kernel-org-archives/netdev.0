From: Alasdair G Kergon <agk@redhat.com>
Subject: Re: [1/1] Block device throttling [Re: Distributed storage.]
Date: Fri, 31 Aug 2007 22:41:37 +0100
Message-ID: <20070831214137.GD30122@agk.fab.redhat.com>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708281408.06618.phillips@phunq.net> <20070829085331.GA16607@2ka.mipt.ru> <200708301620.37965.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Neil Brown <neilb@suse.de>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37832 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756717AbXHaVnc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 17:43:32 -0400
Content-Disposition: inline
In-Reply-To: <200708301620.37965.phillips@phunq.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2007 at 04:20:35PM -0700, Daniel Phillips wrote:
> Resubmitting a bio or submitting a dependent bio from 
> inside a block driver does not need to be throttled because all 
> resources required to guarantee completion must have been obtained 
> _before_ the bio was allowed to proceed into the block layer.

I'm toying with the idea of keeping track of the maximum device stack
depth for each stacked device, and only permitting it to increase in
controlled circumstances.

Alasdair
-- 
agk@redhat.com
