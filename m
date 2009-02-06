From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] forcedeth: make msi-x different name for rx-tx
Date: Fri, 6 Feb 2009 18:15:44 +0100
Message-ID: <20090206171544.GA16190@elte.hu>
References: <498BC3A8.9040203@kernel.org> <20090206144948.GD18368@elte.hu> <498C6C15.3050807@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759908AbZBFRQ3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <498C6C15.3050807@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Yinghai Lu <yinghai@kernel.org> wrote:

> Ingo Molnar wrote:
> > Cool cleanups!
> > 
> > Would you mind to also fix the following - on all my systems that have 
> > forcedeth gigabit ethernet i've been getting these bogus warnings for 
> > _years_, under moderate load:
> > 
> >   eth2: too many iterations (16) in nv_nic_irq.
> > 
> > I think a 64 iterations limit will work much better. (i tried a limit of 50 
> > a year ago for a while and it worked fine and had no side effects - and the 
> > bogus warnings were done.)
> 
> you may enable CONFIG_FORCEDETH_NAPI.
> 
> we should enable NAPI for forcedeth by default, and try to squash more bugs out.

i do have that:

 CONFIG_FORCEDETH=y
 CONFIG_FORCEDETH_NAPI=y

and the messages still come.

	Ingo
