From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Sun, 1 Nov 2009 11:25:07 -0800
Message-ID: <20091101112507.7ab6c7e8@nehalam>
References: <200911010503.nA153ESA019066@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <adapter_linux_open_src_team@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34223 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751834AbZKATZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Nov 2009 14:25:28 -0500
In-Reply-To: <200911010503.nA153ESA019066@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 Oct 2009 22:03:14 -0700
Rasesh Mody <rmody@brocade.com> wrote:

> +/**
> + * bna_rxf_config_clear()
> + *
> + *   For RxF "rxf_id", it clear its configuration and indicates to the
> + *   statistics collector to stop collecting statistics for this
> + *   Rx-Function.
> + *
> + * @param[in]  dev     - pointer to BNA device structure
> + * @param[in]  rxf_id  - rx-function ID.
> + *
> + * @return BNA_OK   - successful
> + * @return BNA_FAIL - failed on sanity checks.
> + */

This and other docbook style comments do not match code,
and will produce warnings if ever run through docbook

-- 
