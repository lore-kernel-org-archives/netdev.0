From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [0/4] DST: Distributed storage.
Date: Tue, 4 Dec 2007 16:56:26 +0000
Message-ID: <20071204165625.GA14995@infradead.org>
References: <aqqqqasdzxczc036@2ka.mipt.ru> <11967790263179@2ka.mipt.ru> <170fa0d20712040725o506a47cayb137993041ec3a63@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Mike Snitzer <snitzer@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <170fa0d20712040725o506a47cayb137993041ec3a63@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >  * fixed bug with XFS metadata update (it can provide slab pages to the
> >         DST, so it is not allowed to transfer them using ->sendpage())

xfs hasn't been doing that anymore for quite a while.  Block drivers
don't need hacks for it anymore, epsecially as it's not reliably
detectable.

