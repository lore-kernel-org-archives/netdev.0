From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: fix incorrect use of ntohs()
Date: Sat, 01 Dec 2012 11:37:15 -0500 (EST)
Message-ID: <20121201.113715.969728576750598213.davem@davemloft.net>
References: <1354314686-16149-1-git-send-email-gallatin@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab2LAQhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 11:37:16 -0500
In-Reply-To: <1354314686-16149-1-git-send-email-gallatin@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Fri, 30 Nov 2012 17:31:26 -0500

> 1b4c44e6369dbbafd113f1e00b406f1eda5ab5b2 incorrectly used
> ntohs() rather than htons() in myri10ge_vlan_rx().
> 
> Thanks to Fengguang Wu, Yuanhan Liu's kernel-build tester
> for pointing out this bug.
> 
> Signed-off-by: Andrew Gallatin <gallatin@myri.com>

Applied.
