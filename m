From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Block device throttling [Re: Distributed storage.]
Date: Wed, 8 Aug 2007 13:54:49 +0400
Message-ID: <20070808095448.GA3440@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708051423.45484.phillips@phunq.net> <20070807120523.GX5245@kernel.dk> <200708071124.56859.phillips@phunq.net> <20070807205538.GB5245@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Phillips <phillips@phunq.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070807205538.GB5245@kernel.dk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 07, 2007 at 10:55:38PM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> I don't like structure bloat, but I do like nice design. Overloading is

So, what did we decide? To bloat bio a bit (add a queue pointer) or to
use physical device limits? The latter requires to replace all occurence
of bio->bi_bdev = something_new with blk_set_bdev(bio, somthing_new),
where queue limits will be appropriately charged. So far I'm testing
second case, but I only changed DST for testing, can change all other
users if needed though.

-- 
	Evgeniy Polyakov
