From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] gre: receive also TEB packets for
 lwtunnels
Date: Wed, 04 May 2016 14:11:50 -0400 (EDT)
Message-ID: <20160504.141150.1172239925654406356.davem@davemloft.net>
References: <cover.1462286214.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, pshelar@ovn.org,
	simon.horman@netronome.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755180AbcEDSLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 14:11:53 -0400
In-Reply-To: <cover.1462286214.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue,  3 May 2016 17:10:05 +0200

> NOTE: this patchset needs net merged to net-next.

Noted.

> This allows lwtunnel users to get also packets with ETH_P_TEB protocol
> specified in GRE header through an ipgre interface. There's really nothing
> special about these packets in the case of lwtunnels - it's just an inner
> protocol like any other. The only complications stem from keeping
> compatibility with other uses of GRE.
> 
> This will be used by openvswitch to support eth_push and eth_pop actions.
> I'd also like to see tc support for lwtunnels (this feature included) in the
> future.
> 
> The first patch is not directly related and can be submitted standalone if
> needed.

Series applied, thanks Jiri.
