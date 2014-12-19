From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Thu, 18 Dec 2014 23:21:09 -0800
Message-ID: <20141218232109.2c5a8680@urahara>
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
Received: from mail-pa0-f41.google.com ([209.85.220.41]:58735 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbaLSHVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 02:21:20 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so658641pab.14
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 23:21:20 -0800 (PST)
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Dec 2014 19:25:19 -0800
Raghu Vatsavayi <rvatsavayi@caviumnetworks.com> wrote:

> +static int liquidio_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
> +{
> +	switch (cmd) {
> +	case SIOCSHWTSTAMP:
> +		return hwtstamp_ioctl(netdev, ifr, cmd);
> +	default:
> +		return -EINVAL

Standard error code for unsupported ioctl is -EOPNOTSUPP
