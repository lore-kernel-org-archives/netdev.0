From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] dcbnl: Major simplifications
Date: Wed, 13 Jun 2012 15:55:41 -0700 (PDT)
Message-ID: <20120613.155541.26513304496438357.davem@davemloft.net>
References: <cover.1339591572.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lucy.liu@intel.com,
	john.r.fastabend@intel.com, alexander.h.duyck@intel.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754791Ab2FMWzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 18:55:42 -0400
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 13 Jun 2012 14:54:53 +0200

> The dcbnl code is overly complicated when constructing the reply
> message. This series of patches simplifies the process and
> introduces consistent error codes allowing user space to figure
> out what went wrong.
> 
> Patches have been tested with ixgbe in a FCoE setup.
> 
> Thomas Graf (8):
>   dcbnl: Prepare framework to shorten handling functions
>   dcbnl: Shorten all command handling functions
>   dcbnl: Remove now unused dcbnl_reply()
>   dcbnl: Use dcbnl_newmsg() where possible
>   dcbnl: Return consistent error codes
>   dcbnl: Move dcb app lookup code into dcb_app_lookup()
>   dcbnl: Move dcb app allocation into dcb_app_add()
>   dcbnl: Use type safe nlmsg_data()

Lots of deleted code, I like it :-)

Applied, but could you send a follow-on patch to use BUG_ON() instead
of that "if (!ptr) { /* ... */ BUG(); }" construct?

Thanks.
