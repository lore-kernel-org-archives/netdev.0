From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 23 Nov 2009 20:24:53 -0800
Message-ID: <20091123202453.0a6b5ac6@s6510>
References: <200911240351.nAO3p1AY025627@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <adapter_linux_open_src_team@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57134 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757953AbZKXEZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 23:25:10 -0500
In-Reply-To: <200911240351.nAO3p1AY025627@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Nov 2009 19:51:01 -0800
Rasesh Mody <rmody@brocade.com> wrote:

> /**
> + * bna_mcast_mac_reset_list()
> + *
> + *  Resets the multicast MAC address list kept by driver.
> + *  Called when the hw gets reset.
> + *
> + * @param[in]  dev  - pointer to BNA device structure
> + *
> + * @return BNA_OK   - successful
> + * @return BNA_FAIL - failed on sanity checks.
> + */
> +void bna_mcast_mac_reset_list(struct bna_dev *dev)
> +{
> +	memset(&dev->mcast_addr[0], 0, sizeof(dev->mcast_addr));
> +}
> +

If you are going to wrap and add kernel-doc to everything,
please check (or get rid of the boilerplate).  This obviously doesn't
take param[in] or return those values.
