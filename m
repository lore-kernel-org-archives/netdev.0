From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] sh_eth: Change handling of IRQ
Date: Tue, 31 Mar 2009 08:16:23 +0900
Message-ID: <20090330231623.GH19535@linux-sh.org>
References: <49BF3A97.4010008@renesas.com> <49BF3A41.6040309@renesas.com> <20090330231513.GG19535@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>,
	netdev@vger.kernel.org, Linux-sh <linux-sh@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090330231513.GG19535@linux-sh.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 31, 2009 at 08:15:13AM +0900, Paul Mundt wrote:
> On Tue, Mar 17, 2009 at 02:50:57PM +0900, Nobuhiro Iwamatsu wrote:
> > Handling of IRQ of the SH7763/SH7764 CPU which sh_eth supported was
> > changed.
> > This revises it for this change.
> > 
> > Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
> 
> On Tue, Mar 17, 2009 at 02:52:23PM +0900, Nobuhiro Iwamatsu wrote:
> > Address of SH_TSU_ADDR and ARSTR of SH7763 was wrong.
> > This revise it.
> > 
> > Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
> 
> The sh changes this depends on for the CPU subtypes are merged upstream
> now, so this can go through either tree. As there is nothing really
> netdev specific about this, I suppose the easiest is to just roll both of
> these in to the sh tree.

Oh, nevermind, I see these were merged already through the net tree..
