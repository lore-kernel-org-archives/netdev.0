From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] ethtool: add RX_ALLOC_ORDER to tunable
Date: Mon, 02 Feb 2015 19:21:59 -0800 (PST)
Message-ID: <20150202.192159.66698996958688718.davem@davemloft.net>
References: <1422707290-939-1-git-send-email-_govind@gmx.com>
	<1422707290-939-4-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com,
	edumazet@google.com, ben@decadent.org.uk
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932126AbbBCDWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 22:22:00 -0500
In-Reply-To: <1422707290-939-4-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Sat, 31 Jan 2015 17:58:09 +0530

> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

This is terrible.

You haven't explained what this means.

And to tell you the truth, from what I can tell this tunable is
very specific to how you have implemented RX frags in the enic
driver in this series and won't necessarily translate to how
other drivers manage RX buffers.

You need to actually design this facility properly, understand
what the needs are of other drivers and how this facility
can be relevant for more drivers than your own.
