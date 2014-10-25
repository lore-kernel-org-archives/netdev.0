From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv5 net-next 1/4] sunvnet: NAPIfy sunvnet
Date: Sat, 25 Oct 2014 14:26:03 -0400 (EDT)
Message-ID: <20141025.142603.1640723028009535224.davem@davemloft.net>
References: <20141022221225.GC17252@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bob.picco@oracle.com, dwight.engen@oracle.com,
	raghuram.kothakota@oracle.com, david.stevens@oracle.com,
	netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbaJYS0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 14:26:06 -0400
In-Reply-To: <20141022221225.GC17252@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 22 Oct 2014 18:12:25 -0400

> +#define	NAPI_POLL_WEIGHT	64

Do not redefine this value, and just use the default provided
by netdevice.h's definition.
