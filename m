From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH 12/12] netfilter: bridge: move DNAT helper to br_netfilter
Date: Tue, 10 Mar 2015 14:28:48 +0900
Message-ID: <20150310052845.GA12887@vergenet.net>
References: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
 <1425921275-9171-13-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1425921275-9171-13-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

On Mon, Mar 09, 2015 at 06:14:35PM +0100, Pablo Neira Ayuso wrote:
> Only one caller, there is no need to keep this in a header.
> Move it to br_netfilter.c where this belongs to.
> 
> Based on patch from Florian Westphal.

net-next seems fail to compile due to this patch if
CONFIG_BRIDGE_NETFILTER=m and CONFIG_BRIDGE=y which happened to be a
configuration I had for some reason.

net/bridge/br_device.c:39: undefined reference to `br_nf_prerouting_finish_bridge'
