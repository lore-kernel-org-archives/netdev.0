From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Mon, 19 Sep 2011 19:47:33 -0400 (EDT)
Message-ID: <20110919.194733.2285944272507495065.davem@davemloft.net>
References: <1316475390.2184.8.camel@jtkirshe-mobl>
	<19fca01e-5827-4e28-b12c-2b65cca96878@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab1ISXrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 19:47:47 -0400
In-Reply-To: <19fca01e-5827-4e28-b12c-2b65cca96878@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Mon, 19 Sep 2011 16:42:31 -0700 (PDT)

> I would like to see a general solution to allow configuring
> napi weight. The Rx weight isn't easily configurable either.
> Probably needs to be through ethtool callback since actual value range
> and dev -> napi relationship is device specific.

Agreed, it probably has to be per-queue too.
