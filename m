From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/9] net: Introduce VRF related flags and
 helpers
Date: Tue, 11 Aug 2015 11:08:33 -0700 (PDT)
Message-ID: <20150811.110833.1381838590302139426.davem@davemloft.net>
References: <1439229037-79213-1-git-send-email-dsa@cumulusnetworks.com>
	<1439229037-79213-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, hannes@stressinduktion.org,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hadi@mojatatu.com, ebiederm@xmission.com, svaidya@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657AbbHKSIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 14:08:34 -0400
In-Reply-To: <1439229037-79213-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 10 Aug 2015 11:50:28 -0600

> +static inline int vrf_dev_table(const struct net_device *dev)
> +{
> +	int tb_id = 0;
> +
> +	rcu_read_lock();
> +	tb_id = vrf_dev_table_rcu(dev);
> +	rcu_read_unlock();
> +
> +	return tb_id;
> +}

The initialization of "tb_id" to zero in the variable declaration is
unnecessary, please remove it.
