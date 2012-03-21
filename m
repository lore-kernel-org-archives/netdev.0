From: Sujith Manoharan <c_manoha@qca.qualcomm.com>
Subject: Re: [PATCH v3 4/4] ath9k:  Support ethtool getstats api.
Date: Wed, 21 Mar 2012 12:37:58 +0530
Message-ID: <20329.32334.162938.169995@gargle.gargle.HOWL>
References: <1332183105-4447-1-git-send-email-greearb@candelatech.com>
	<1332183105-4447-4-git-send-email-greearb@candelatech.com>
	<4F684301.9040006@openwrt.org>
	<4F68B4AA.3070306@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:30042 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756722Ab2CUHIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 03:08:42 -0400
In-Reply-To: <4F68B4AA.3070306@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> I'd like to gather at least most stats always, so ethtool can work regardless
> of debugfs.  But, that can be follow on patches in my opinion.  If it turns
> out that we need another config option for this, then that is fine too.

It would be good to have an option to compile this out. The information is
available via the debugfs interface, so this is basically duplicating things.
On APs using OpenWRT, debugfs is enabled by default, so we can just read
the debugfs files.

Sujith
