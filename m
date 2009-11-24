From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 23 Nov 2009 20:22:44 -0800
Message-ID: <20091123202244.56ce6cb5@s6510>
References: <200911240351.nAO3p1AY025627@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <adapter_linux_open_src_team@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56973 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756788AbZKXEWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 23:22:49 -0500
In-Reply-To: <200911240351.nAO3p1AY025627@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Nov 2009 19:51:01 -0800
Rasesh Mody <rmody@brocade.com> wrote:

> /**
> + * bna_uninit()
> + *
> + *   Called by the driver during removal/unload.
> + *
> + * @param[in]  bna_handle  - pointer to BNA device structure
> + *			     allocated by the calling driver
> + *
> + * @return BNA_OK   - successful
> + * @return BNA_FAIL - failed on sanity checks.
> + */
> +enum bna_status_e bna_uninit(void *bna_handle)
> +{
> +	return BNA_OK;
> +}

Useless extra bloat?
