From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] tun: don't look at current when non-blocking
Date: Wed, 9 Oct 2013 11:13:54 +0300
Message-ID: <20131009081354.GA30882@redhat.com>
References: <20131006182512.GA16504@redhat.com>
 <20131008.154614.1435858706789904414.davem@davemloft.net>
 <5254F6CF.8080606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	xemul@parallels.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5254F6CF.8080606@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 09, 2013 at 02:25:19PM +0800, Jason Wang wrote:
> On 10/09/2013 03:46 AM, David Miller wrote:
> > From: "Michael S. Tsirkin" <mst@redhat.com>
> > Date: Sun, 6 Oct 2013 21:25:12 +0300
> >
> >> We play with a wait queue even if socket is
> >> non blocking. This is an obvious waste.
> >> Besides, it will prevent calling the non blocking
> >> variant when current is not valid.
> >>
> >> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > Applied and queued up for -stable, thanks.
> > --
> 
> Michael, I believe this is just an optimization or a required patch of
> your following patches. So no need go for stable?

I don't think it's required for stable.
