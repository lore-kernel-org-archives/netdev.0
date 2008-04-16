From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: X or AF_UNIX and order 3 allocation
Date: Wed, 16 Apr 2008 08:52:13 -0700
Message-ID: <20080416085213.1e55bd1e@extreme>
References: <20080415211055.882e67fe.zaitcev@redhat.com>
	<20080415.215144.87148045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: zaitcev@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759679AbYDPPwc@vger.kernel.org>
In-Reply-To: <20080415.215144.87148045.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Apr 2008 21:51:44 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Pete Zaitcev <zaitcev@redhat.com>
> Date: Tue, 15 Apr 2008 21:10:55 -0700
> 
> > Hi, Guys:
> > 
> > Not sure if the problem is caused by X or kernel, but this is what
> 
> It seems to be the b44 driver doing a large huge order allocation.
> 
> That driver only asks for (1536 + 30 + 64) bytes, so I suppose part of
> the problem is that SLAB is using an order 3 allocation to satisfy
> that.
>

The chip needs memory below 1G for DMA, perhaps low memory is getting
exhausted.
