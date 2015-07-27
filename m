From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: convert num_grat_arp to the new
 bonding option API
Date: Mon, 27 Jul 2015 01:05:36 -0700 (PDT)
Message-ID: <20150727.010536.1251148862319425028.davem@davemloft.net>
References: <1437745831-10273-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39000 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbbG0IFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:05:37 -0400
In-Reply-To: <1437745831-10273-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Fri, 24 Jul 2015 15:50:31 +0200

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> num_grat_arp wasn't converted to the new bonding option API, so do this
> now and remove the specific sysfs store option in order to use the
> standard one. num_grat_arp is the same as num_unsol_na so add it as an
> alias with the same option settings. An important difference is the option
> name which is matched in bond_sysfs_store_option().
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Nice work, applied, thanks.
