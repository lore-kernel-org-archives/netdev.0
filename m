From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add unknown state to sysfs NIC duplex export
Date: Wed, 05 Sep 2012 17:40:55 -0400 (EDT)
Message-ID: <20120905.174055.2000797689147082508.davem@davemloft.net>
References: <1346854288-6380-1-git-send-email-naleksan@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: naleksan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754936Ab2IEVk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 17:40:56 -0400
In-Reply-To: <1346854288-6380-1-git-send-email-naleksan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <naleksan@redhat.com>
Date: Wed,  5 Sep 2012 16:11:28 +0200

>  Currently when the NIC duplex state is DUPLEX_UNKNOWN it is exported as
>  full through sysfs, this patch adds support for DUPLEX_UNKNOWN. It is
>  handled the same way as in ethtool.
> 
>  Signed-off-by: Nikolay Aleksandrov <naleksan@redhat.com>

Applied with two minor corrections:

> +			char *duplex;

I made this "const char *"

> +			switch(cmd.duplex) {

I added the missing space between 'switch' and '(cmd.duplex)'.

Thanks.
