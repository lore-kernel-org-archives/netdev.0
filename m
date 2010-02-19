From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: NAT regression in next tree
Date: Thu, 18 Feb 2010 21:51:06 -0800
Message-ID: <20100218215106.557be6b0@nehalam>
References: <20100216173658.519b6245@nehalam>
	<201002171526.02493.arnd@arndb.de>
	<20100218173633.30bb8c41@nehalam>
	<4B7E2587.3050608@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B7E2587.3050608@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Feb 2010 06:45:43 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > Something in net-next tree broke bridging of virtual nets.
> > My local VM's can no longer access external networks.
> > 
> > It is a NAT problem. One of the recent netfilter changes is causing
> > the packets to not have there source address rewritten.
> > 
> > I see:
> >     VM1  -- 192.168.100.0/24 -- HOST -- 192.168.1.0/24 -- ROUTER
> >                            virbr0    eth0
> > 
> > Even a simple ping from VM1 doesn't get responded to because
> > the 192.168.100.X source address is not getting rewritten.
> 
> I'll try to reproduce it locally. What is the HEAD of the broken
> tree you're running?

commit 37ee3d5b3e979a168536e7e2f15bd1e769cb4122
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Feb 18 19:04:44 2010 +0100

    netfilter: nf_defrag_ipv4: fix compilation error with NF_CONNTRACK=n



-- 
