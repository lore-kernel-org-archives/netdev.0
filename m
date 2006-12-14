From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 6/6] d80211: add sysfs interface for QoS functions
Date: Wed, 13 Dec 2006 20:43:28 -0800
Message-ID: <20061213204328.765b8672@localhost.localdomain>
References: <20061214040302.GA10689@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:48016 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751494AbWLNEnm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 23:43:42 -0500
To: yi.zhu@intel.com
In-Reply-To: <20061214040302.GA10689@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

O
> +static ssize_t store_tspec(struct class_device *dev, const char *buf,
> +			   size_t len)
> +{
> +	if (sscanf(buf, "%hu %hu %u %u %u %u %u %u %u %u %u %u %u %hu %hu",
> +		   &_tspec.nominal_msdu_size,
> +		   &_tspec.max_msdu_size,
> +		   &_tspec.min_service_interval,
> +		   &_tspec.max_service_interval,
> +		   &_tspec.inactivity_interval,
> +		   &_tspec.suspension_interval,
> +		   &_tspec.service_start_time,
> +		   &_tspec.min_data_rate,
> +		   &_tspec.mean_data_rate,
> +		   &_tspec.peak_data_rate,
> +		   &_tspec.burst_size,
> +		   &_tspec.delay_bound,
> +		   &_tspec.min_phy_rate,
> +		   &_tspec.surplus_band_allow,
> +		   &_tspec.medium_time) != 15) {
> +		printk(KERN_ERR "%s: sscanf error\n", __FUNCTION__);
> +

One value per file please!
