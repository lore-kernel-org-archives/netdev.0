From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/7] net: Support checksum in UDP
Date: Wed, 04 Jun 2014 23:02:19 -0700 (PDT)
Message-ID: <20140604.230219.1252048889879684806.davem@davemloft.net>
References: <alpine.DEB.2.02.1406041705230.14524@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbaFEGCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 02:02:23 -0400
In-Reply-To: <alpine.DEB.2.02.1406041705230.14524@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 4 Jun 2014 17:19:42 -0700 (PDT)

> This patch series adds support for using checksums in UDP tunnels. With
> this it is possible that two or more checksums may be set within the
> same packet and we would like to do that efficiently.
> 
> This series also creates some new helper functions to be used by various
> tunnel protocol implementations.
> 
> v2: Fixed indentation in tcp_v6_send_check arguments.
> v3: Move udp_set_csum and udp6_set_csum to be not inlined
>     Also have this functions call with a nocheck boolean argument
>     instead of passing a sock structure.

Series applied, thanks for all of your hard work Tom.
