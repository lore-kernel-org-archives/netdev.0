From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
 RLT-8139 related)
Date: Mon, 26 Jul 2004 09:55:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040726095505.2ddb3bec@dell_ss3.pdx.osdl.net>
References: <20040725235927.B30025@electric-eye.fr.zoreil.com>
	<Pine.LNX.4.44.0407261745120.31123-100000@silmu.st.jyu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        H?ctor Mart?n
 <hector@marcansoft.com>,
        Linux-Kernel <linux-kernel@vger.kernel.org>, <akpm@osdl.org>,
        <netdev@oss.sgi.com>, <brad@brad-x.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
In-Reply-To: <Pine.LNX.4.44.0407261745120.31123-100000@silmu.st.jyu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 26 Jul 2004 18:15:34 +0300 (EEST)
Pasi Sjoholm <ptsjohol@cc.jyu.fi> wrote:

> On Sun, 25 Jul 2004, Francois Romieu wrote:
> 
> > Pasi Sjoholm <ptsjohol@cc.jyu.fi> :
> > [...]
> > > I haven't been able to reproduce this with normal www-browsing or 
> > > ssh-connections but it's always reproducible when my eth0 is under heavy 
> > > load.
> > I guess it can be reproduced even if the binary (nvidia ?) module is never
> > loaded after boot, right ?
> 
> After 24 hours of hard working I can answer yes to this question. 
> Now I can reproduce this from 2 to 15 minutes with 2 cp-processes from 
> samba->workstation->nfs, some software building with make -j 3, playing 
> some mp3 via nfs to notice when kernel goes down.. =) and so on..
> 
> After that ksoftirqd takes almost all the cpu-time and the network is not 
> working at all.

Is network traffic still coming in? or perhaps there is a network packet
that causes some soft irq to go into an infinite loop. The recent iptables bug
with ip options would be an example.
