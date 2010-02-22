From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: Subject: [PATCH 4/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 22 Feb 2010 13:42:20 +0100
Message-ID: <20100222124219.GE2520@dhcp-lab-161.englab.brq.redhat.com>
References: <201002192152.o1JLqcTh031965@blc-10-1.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3329 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752502Ab0BVMoP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 07:44:15 -0500
Content-Disposition: inline
In-Reply-To: <201002192152.o1JLqcTh031965@blc-10-1.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2010 at 01:52:38PM -0800, Rasesh Mody wrote:
> From: Rasesh Mody <rmody@brocade.com>
> 
> This is patch 4/6 which contains linux driver source for
> Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
> Source is based against net-next-2.6.
> 
> We wish this patch to be considered for inclusion in net-next-2.6
> 
> Signed-off-by: Rasesh Mody <rmody@brocade.com>
> ---
>  bfa_ioc.h   |  320 ++++++++
>  bna.h       | 2195 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  bna_hwreg.h |  910 ++++++++++++++++++++++++
>  bna_intr.h  |   96 ++
>  4 files changed, 3521 insertions(+)
[snip]

> +/**
> + * Ethernet / Ethernet & VLAN header used by diag loopback
> + */
> +struct bna_ether_hdr {
> +	struct mac dst;		/* destination mac address      */
> +	struct mac src;		/* source mac address		*/
> +	u16 proto;		/* ethernet protocol		*/
> +};
Not used ?

> +
> +struct bna_ether_vlan_hdr {
> +	struct mac dst;		/* destination mac address      */
> +	struct mac src;		/* source mac address		*/
> +	u16 vlan_proto;	/* vlan ethernet protocol	*/
> +	u16 vlan_tci;	/* vlan tag/priority		*/
> +	u16 proto;		/* ethernet protocol		*/
> +};

Not used ?

