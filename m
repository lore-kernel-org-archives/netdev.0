From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] cxgb4: core hardware/firmware support for
 Forward Error Correction on a link
Date: Mon, 26 Jun 2017 23:16:56 -0400 (EDT)
Message-ID: <20170626.231656.1320688765024223168.davem@davemloft.net>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
        <1498331985-8525-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
        vidya.chowdary@gmail.com, dustin@cumulusnetworks.com,
        olson@cumulusnetworks.com, leedom@chelsio.com,
        manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        galp@mellanox.com, jeffrey.t.kirsher@intel.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751460AbdF0DQ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 23:16:59 -0400
In-Reply-To: <1498331985-8525-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Sat, 24 Jun 2017 12:19:44 -0700

> @@ -3690,11 +3690,64 @@ void t4_ulprx_read_la(struct adapter *adap, u32 *la_buf)
>  		     FW_PORT_CAP_SPEED_40G | FW_PORT_CAP_SPEED_100G | \
>  		     FW_PORT_CAP_ANEG)
>  
> +/* Translate Firmware Port Capabilities Pause specification to Common Code */
> +static inline unsigned int fwcap_to_cc_pause(unsigned int fw_pause)
> +{

Do not use "inline" in foo.c files, always let the compiler decide.

Same goes for patch #3.
