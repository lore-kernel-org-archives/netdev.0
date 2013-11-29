From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] Fixes T5 adapter init, due to incorrect FW
 version check
Date: Fri, 29 Nov 2013 16:45:18 -0500 (EST)
Message-ID: <20131129.164518.76867516422095836.davem@davemloft.net>
References: <1385646734-3576-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755460Ab3K2VpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 16:45:20 -0500
In-Reply-To: <1385646734-3576-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu, 28 Nov 2013 19:22:11 +0530

> This patch series fixes, Chelsio T5 adapter initialization failure due to
> incorrect firmware version check. This patch series modifies the firmware
> flashing mechanism for T4/T5 adapter. It adds a new module parameter
> t4_fw_install to control firmware flashing.

Module parameters are strongly discouraged, please find another way to
control this attribute, preferrably at run time so that it can be changed
right before the device is openned for the first time, for example.

Also, "upgradation" is not a real word, please fix this.
