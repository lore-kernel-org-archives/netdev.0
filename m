From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 2/6] ehea: pHYP interface
Date: Sat, 12 Aug 2006 07:13:14 +1000
Message-ID: <20060811211314.GF479@krispykreme>
References: <44D99F1A.4080905@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Thomas Klein <tklein@de.ibm.com>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.tip.net.au ([203.10.76.45]:33250 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S932083AbWHKVOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 17:14:08 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <44D99F1A.4080905@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

> --- linux-2.6.18-rc4-orig/drivers/net/ehea/ehea_phyp.c	1969-12-31 16:00:00.000000000 -0800

> +u64 ehea_h_alloc_resource_eq(const u64 hcp_adapter_handle,
...
> +u64 hipz_h_reregister_pmr(const u64 adapter_handle,
...
> +static inline int hcp_galpas_ctor(struct h_galpas *galpas,

Be nice to have some consistent names, hipz_ and hcp_ is kind of
cryptic.

> +#define H_QP_CR_STATE_RESET	    0x0000010000000000	/*  Reset */

Probably want ULL on here and the other 64bit constants.

Anton
