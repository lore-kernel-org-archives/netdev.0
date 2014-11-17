From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: linux-next: manual merge of the tiny tree with the net-next tree
Date: Mon, 17 Nov 2014 00:09:19 -0800
Message-ID: <20141117080919.GD18179@thin>
References: <20141117163503.6543cd21@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Iulia Manda <iulia.manda21@gmail.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141117163503.6543cd21@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 17, 2014 at 04:35:03PM +1100, Stephen Rothwell wrote:
> Hi Josh,
> 
> Today's linux-next merge of the tiny tree got a conflict in
> net/openvswitch/Kconfig between commit 8cd4313aa775 ("openvswitch: Fix
> build failure") from the net-next tree and commit b043d487e255 ("lib:
> Conditionally compile flex_array") from the tiny tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Looks good to me.

> diff --cc net/openvswitch/Kconfig
> index b7d818c59423,1d979cecd66e..000000000000
> --- a/net/openvswitch/Kconfig
> +++ b/net/openvswitch/Kconfig
> @@@ -4,9 -4,8 +4,10 @@@
>   
>   config OPENVSWITCH
>   	tristate "Open vSwitch"
>  +	depends on INET
>   	select LIBCRC32C
>  +	select NET_MPLS_GSO
> + 	select FLEX_ARRAY
>   	---help---
>   	  Open vSwitch is a multilayer Ethernet switch targeted at virtualized
>   	  environments.  In addition to supporting a variety of features
