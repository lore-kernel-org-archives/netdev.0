From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 5/7] rocker: add FDB cleanup timer
Date: Mon, 21 Sep 2015 17:11:15 -0700 (PDT)
Message-ID: <20150921.171115.696476792528572981.davem@davemloft.net>
References: <1442764109-11110-1-git-send-email-sfeldma@gmail.com>
	<1442764109-11110-6-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754613AbbIVALS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 20:11:18 -0400
In-Reply-To: <1442764109-11110-6-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Sun, 20 Sep 2015 08:48:27 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Add a timer to each rocker switch to do FDB entry cleanup by ageing out
> expired entries.  The timer scheduling algo is copied from the bridge
> driver, for the most part, to keep the firing of the timer to a minimum.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>

You need to del_timer_sync() or similar on this timer in
rocker_remove().
