From: Kai Makisara <Kai.Makisara@kolumbus.fi>
Subject: Re: e1000 lockup in linux 2.6.9-rc2
Date: Tue, 21 Sep 2004 00:25:32 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0409210023490.2075@kai.makisara.local>
References: <Pine.LNX.4.58.0409202339050.2170@kai.makisara.local>
 <20040920135606.7a0885df.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040920135606.7a0885df.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Sep 2004, David S. Miller wrote:

> On Mon, 20 Sep 2004 23:53:15 +0300 (EEST)
> Kai Makisara <Kai.Makisara@kolumbus.fi> wrote:
> 
> > When I started large data transfers in 100 Mb/s network, my computer very 
> > soon locked totally (i.e., not responding to network, keyboard and mouse 
> > dead). This had not happened for several days with 2.6.9-rc2 when the 
> > network activity had been light (1 Mb/s DSL).
> > 
> > Some experimentation showed that the lockups were caused by this patch 
> > fragment in 2.6.9-rc2:
> 
> Please make sure you have this patch in your
> tree, it should fix your problem:
> 
I did not have this patch. Installed it and I can confirm that it fixes 
the problem.

Thanks,
-- 
Kai
