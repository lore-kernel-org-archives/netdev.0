From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: linux-next: Tree for Oct 2 (vxlan.c)
Date: Tue, 2 Oct 2012 14:21:28 -0700
Message-ID: <20121002142128.1d2fde14@nehalam.linuxnetplumber.net>
References: <20121002163229.d377074dc8f6c029428faeaa@canb.auug.org.au>
	<506B3317.5090006@xenotime.net>
	<20121002.143627.1565408497543880722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20121002.143627.1565408497543880722.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 02 Oct 2012 14:36:27 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Randy Dunlap <rdunlap@xenotime.net>
> Date: Tue, 02 Oct 2012 11:31:51 -0700
> 
> > on x86_64:
> > 
> > drivers/net/vxlan.c: In function 'vxlan_xmit':
> > drivers/net/vxlan.c:725:2: error: implicit declaration of function 'ip_select_ident'
> > 
> > That function is only defined when CONFIG_INET is enabled,
> > but it is disabled in this config.
> 
> This definitely depends upon INET, I'll add the Kconfig change
> to net-next, thanks.

Yup, thanks Dave.
