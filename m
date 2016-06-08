From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fragment large datagrams even when IP_HDRINCL is
 set.
Date: Wed, 08 Jun 2016 10:25:58 -0700 (PDT)
Message-ID: <20160608.102558.903056863834035706.davem@davemloft.net>
References: <1464013425-31129-1-git-send-email-alan.davey@metaswitch.com>
	<20160531.113913.1477085966766110028.davem@davemloft.net>
	<BN3PR0201MB1059316BEC3EC7F6CBF2F0E4F95E0@BN3PR0201MB1059.namprd02.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Alan.Davey@metaswitch.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933086AbcFHR0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 13:26:03 -0400
In-Reply-To: <BN3PR0201MB1059316BEC3EC7F6CBF2F0E4F95E0@BN3PR0201MB1059.namprd02.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Davey <Alan.Davey@metaswitch.com>
Date: Wed, 8 Jun 2016 08:41:31 +0000

> -  The current behaviour is counter-intuitive (fragmentation takes
> -  place in all other cases) and therefore different to what
> -  everyone expects.

But it's what all existing applications must expect, and as you have
seen in these replied they absolutely do.

You cannot just break things on people like this.
