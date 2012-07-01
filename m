From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] sctp: be more restrictive in transport selection on
 bundled sacks
Date: Sat, 30 Jun 2012 17:38:48 -0700 (PDT)
Message-ID: <20120630.173848.305653960513565624.davem@davemloft.net>
References: <1341000929-22933-1-git-send-email-nhorman@tuxdriver.com>
	<20120629.163408.1111786778802302299.davem@davemloft.net>
	<20120630122647.GA22647@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069Ab2GAAit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 20:38:49 -0400
In-Reply-To: <20120630122647.GA22647@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Sat, 30 Jun 2012 08:26:47 -0400

> This is wrong.  Its a counter that increments every time we call sctp_make_sack,
> so that we can create a unique generation identifier for use in tagging which
> transports move ctsn in a given generation.  It saves us from having to iterate
> over a list every time we send a sack. 

Sorry, I missed the counter bump.
