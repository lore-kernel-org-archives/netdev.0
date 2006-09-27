From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take19 0/4] kevent: Generic event handling mechanism.
Date: Wed, 27 Sep 2006 19:09:57 +0400
Message-ID: <20060927150957.GA18116@2ka.mipt.ru>
References: <115a6230591036@2ka.mipt.ru> <11587449471424@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964897AbWI0PKu@vger.kernel.org>
To: lkml <linux-kernel@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <11587449471424@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 20, 2006 at 01:35:47PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> 
> Generic event handling mechanism.
> 
> Consider for inclusion.

I have been told in private what is signal masks about - just to wait
until either signal or given condition is ready, but in that case just 
add additional kevent user like AIO complete or netwrok notification 
and wait until either requested events are ready or signal is triggered.

-- 
	Evgeniy Polyakov
