From: Debashis Dutt <ddutt@Brocade.COM>
Subject: RE: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Thu, 26 Nov 2009 01:01:11 -0800
Message-ID: <1B6CC3D5ACAB014C8BFB6CB1CBD62CADD28A7D6F77@HQ-EXCH-7.corp.brocade.com>
References: <200911240351.nAO3p1AY025627@blc-10-10.brocade.com>
 <20091123202453.0a6b5ac6@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Akshay Mathur <amathur@brocade.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.82]:22811 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752753AbZKZJBH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 04:01:07 -0500
In-Reply-To: <20091123202453.0a6b5ac6@s6510>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen, 

We have removed the inconsistent comments in our last submission.

Thanks
--Debashis

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@vyatta.com] 
Sent: Monday, November 23, 2009 8:25 PM
To: Rasesh Mody
Cc: netdev@vger.kernel.org; Adapter Linux Open SRC Team
Subject: Re: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver

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
