From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fec_mpc52xx: Read MAC address from device-tree
Date: Tue, 12 Feb 2013 12:05:36 -0500 (EST)
Message-ID: <20130212.120536.2017028310090249045.davem@davemloft.net>
References: <1360660088-27464-1-git-send-email-sr@denx.de>
	<6A3DF150A5B70D4F9B66A25E3F7C888D065A0271@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sr@denx.de, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	agust@denx.de
To: R65777@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933296Ab3BLRFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 12:05:38 -0500
In-Reply-To: <6A3DF150A5B70D4F9B66A25E3F7C888D065A0271@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bhushan Bharat-R65777 <R65777@freescale.com>
Date: Tue, 12 Feb 2013 10:56:05 +0000

> Why we read from MAC registers if Linux should not rely on bootloader?

Because it used to and if you just remove that code then you break
existing setups, and I explicitly told him to code things this way.
