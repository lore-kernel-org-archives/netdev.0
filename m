From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [patch] iwlwifi: range checking issue
Date: Mon, 29 Mar 2010 10:01:12 +0800
Message-ID: <1269828072.4043.247.camel@debian>
References: <20100328115500.GX5069@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Chatre, Reinette" <reinette.chatre@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Kolekar, Abhijeet" <abhijeet.kolekar@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25096 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755588Ab0C2CAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Mar 2010 22:00:32 -0400
In-Reply-To: <20100328115500.GX5069@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-03-28 at 19:55 +0800, Dan Carpenter wrote:
> IWL_RATE_COUNT is 13 and IWL_RATE_COUNT_LEGACY is 12.
> 
> IWL_RATE_COUNT_LEGACY is the right one here because iwl3945_rates
> doesn't support 60M and also that's how "rates" is defined in
> iwlcore_init_geos() from drivers/net/wireless/iwlwifi/iwl-core.c.
> 
>         rates = kzalloc((sizeof(struct ieee80211_rate) * IWL_RATE_COUNT_LEGACY),
>                         GFP_KERNEL);
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Acked-by: Zhu Yi <yi.zhu@intel.com>

Thanks,
-yi

