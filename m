From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Missing byteswap in be_get_fw_log_level causes
 oops on PowerPC
Date: Wed, 25 Jul 2012 15:24:26 -0700 (PDT)
Message-ID: <20120725.152426.2102929158811424789.davem@davemloft.net>
References: <20120725110525.0468f754@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278Ab2GYWY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 18:24:27 -0400
In-Reply-To: <20120725110525.0468f754@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Wed, 25 Jul 2012 11:05:25 +1000

> 
> We are seeing an oops in be_get_fw_log_level on ppc64 where we walk
> off the end of memory.
> 
> commit 941a77d582c8 (be2net: Fix to allow get/set of debug levels in
> the firmware.) requires byteswapping of num_modes and num_modules.
> 
> Cc: stable@vger.kernel.org # 3.5+
> Signed-off-by: Anton Blanchard <anton@samba.org>

Applied.
