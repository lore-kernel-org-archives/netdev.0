From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vmsplice: relax alignement requirements for
 SPLICE_F_GIFT
Date: Fri, 20 Apr 2012 10:35:00 +0200
Message-ID: <1334910900.2395.229.camel@edumazet-glaptop>
References: <1333530531.18626.550.camel@edumazet-glaptop>
	 <20120420081953.GJ7505@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Hugh Dickins <hughd@google.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Miklos Szeredi <mszeredi@suse.cz>
To: Jens Axboe <axboe@kernel.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120420081953.GJ7505@kernel.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-04-20 at 10:19 +0200, Jens Axboe wrote:
> On Wed, Apr 04 2012, Eric Dumazet wrote:
> > It seems there is no fundamental reason to limit vmsplice()
> > SPLICE_F_GIFT to page aligned chunks.
> > 
> > All helpers are prepared to cope with offsets in page.
> > 
> > This limitation makes vmsplice() API very impractical in the zero-copy
> > land.
> 
> Sorry for the slow reply on this one. It's been a long time since I
> wrote that code... If I recall correctly, the reason it currently
> requires alignment, is that a gifted page is no longer yours, by
> definition. So the alignment check was to ensure that we gift full
> pages. But if the caller screws that up, I guess it's the callers
> problem and it's a shame to limit the API in this way.
> 
> I will apply it for 3.5.
> 

Thanks Jens 
