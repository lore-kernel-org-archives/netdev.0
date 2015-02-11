From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Reset key metadata for packet
 execution.
Date: Wed, 11 Feb 2015 14:40:56 -0800 (PST)
Message-ID: <20150211.144056.991311291193384410.davem@davemloft.net>
References: <1423604116-1438-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460AbbBKWdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 17:33:55 -0500
In-Reply-To: <1423604116-1438-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 10 Feb 2015 13:35:16 -0800

> Userspace packet execute command pass down flow key for given
> packet. But userspace can skip some parameter with zero value.
> Therefore kernel needs to initialize key metadata to zero.
> 
> Fixes: 0714812134 ("openvswitch: Eliminate memset() from flow_extract.")
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, but...

> + 	memset(key, 0, OVS_SW_FLOW_KEY_METADATA_SIZE);

There's a space before the TAB in that indentation, and git even
warns about this when applying patches.

I fixed it up, but this is one of the basic things you should be
dealing with before submitting your changes.

Thanks.
