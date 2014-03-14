From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 1/2] ethtool: Support for configurable RSS
 hash key
Date: Fri, 14 Mar 2014 15:02:09 -0400 (EDT)
Message-ID: <20140314.150209.780805827828727740.davem@davemloft.net>
References: <1394794484-12957-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	<0e1a43a0-8126-45f8-97f1-0ede7637a9b0@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: VenkatKumar.Duvvuru@Emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644AbaCNTCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 15:02:11 -0400
In-Reply-To: <0e1a43a0-8126-45f8-97f1-0ede7637a9b0@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Date: Fri, 14 Mar 2014 16:24:43 +0530

> +static inline int ethtool_copy_validate_indir(u32 *indir, void __user *useraddr,

Please don't add explicit inline to functions contained in *.c files, let
the compiler decide.
