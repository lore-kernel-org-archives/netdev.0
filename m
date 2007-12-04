From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [0/4] DST: Distributed storage.
Date: Tue, 4 Dec 2007 20:21:47 +0300
Message-ID: <20071204172146.GA21838@2ka.mipt.ru>
References: <aqqqqasdzxczc036@2ka.mipt.ru> <11967790263179@2ka.mipt.ru> <170fa0d20712040725o506a47cayb137993041ec3a63@mail.gmail.com> <20071204165625.GA14995@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Snitzer <snitzer@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071204165625.GA14995@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 04, 2007 at 04:56:26PM +0000, Christoph Hellwig (hch@infradead.org) wrote:
> > >  * fixed bug with XFS metadata update (it can provide slab pages to the
> > >         DST, so it is not allowed to transfer them using ->sendpage())
> 
> xfs hasn't been doing that anymore for quite a while.  Block drivers
> don't need hacks for it anymore, epsecially as it's not reliably
> detectable.

I use 2.6.22 and it is there, maybe it was changed later.
Right now it can be detected quite trivially, but can result in a little
more bio startup overhead, I just did not know that it was allowed and
thus did not have a check in the DST.

-- 
	Evgeniy Polyakov
