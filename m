From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Thu, 18 Dec 2014 23:07:12 -0800
Message-ID: <20141218230712.5fc9e6b6@urahara>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
	<1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:44603 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbaLSHHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 02:07:22 -0500
Received: by mail-pd0-f182.google.com with SMTP id p10so627649pdj.27
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 23:07:22 -0800 (PST)
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Dec 2014 19:25:19 -0800
Raghu Vatsavayi <rvatsavayi@caviumnetworks.com> wrote:

> +/** \brief Network device get stats
> + * @param netdev    pointer to network device
> + * @returns pointer stats structure
> + */
> +static struct net_device_stats *liquidio_stats(struct net_device *netdev)
> +{
> +	return &(GET_LIO(netdev)->stats);
> +}
> +

Unnecessary function, this is what network core does already
if .ndo_get_stats is NULL;
