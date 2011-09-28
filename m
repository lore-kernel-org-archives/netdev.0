From: David Miller <davem@davemloft.net>
Subject: Re: ICMP redirect issue
Date: Wed, 28 Sep 2011 18:56:54 -0400 (EDT)
Message-ID: <20110928.185654.560483806662347226.davem@davemloft.net>
References: <20110927162120.30394030@asterix.rh>
	<20110928.140632.726302773135946390.davem@davemloft.net>
	<20110928171952.0c0d2d05@asterix.rh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56528 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933456Ab1I1W44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 18:56:56 -0400
In-Reply-To: <20110928171952.0c0d2d05@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Wed, 28 Sep 2011 17:19:52 -0300

> What about something like below? It will change a bit the
> secure_redirects documentation.

The previous check was stronger, and served other purposes.

Firstly, it required that the spoofer know the exact gateway
IP address we used previously, whereas your test requires only
knowing the subnet which is easier to figure out.

But more importantly, the old test allowed us to ignore outdated
or erroneous redirects.

We really have to restore the original behavior before my inetpeer
changes (enforce that the old gateway matches), and find another way
to accomodate IPVS.
