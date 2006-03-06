From: "Chris Leech" <chris.leech@gmail.com>
Subject: Re: [PATCH 1/8] [I/OAT] DMA memcpy subsystem
Date: Mon, 6 Mar 2006 11:39:54 -0800
Message-ID: <41b516cb0603061139qeb60783md1b088ffaa216bf2@mail.gmail.com>
References: <20060303214036.11908.10499.stgit@gitlost.site>
	 <20060303214220.11908.75517.stgit@gitlost.site>
	 <20060303.174048.14793187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751557AbWCFTj5@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060303.174048.14793187.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/3/06, David S. Miller <davem@davemloft.net> wrote:
> > +static spinlock_t dma_list_lock;
>
> Please use DEFINE_SPINLOCK().
>
> > +static void dma_chan_free_rcu(struct rcu_head *rcu) {
>
> Newline before the brace please.
>
> > +static void dma_async_device_cleanup(struct kref *kref) {
>
> Newline before the brace please.
>
> > +struct dma_chan_percpu
> > +{
>
> Left brace on the same line as "struct dma_chan_percpu" please.
>
> > +struct dma_chan
> > +{
>
> Similarly.
>
> Otherwise this patch looks mostly ok.

Thanks Dave,

I'll apply these and other feedback and get updated patches generated.

- Chris
