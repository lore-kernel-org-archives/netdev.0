From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 01/13] put_cmsg_compat + SO_TIMESTAMP[NS]: use same
 name for value as caller
Date: Wed, 12 Nov 2008 01:55:22 -0800 (PST)
Message-ID: <20081112.015522.218226595.davem@davemloft.net>
References: <1226414697.17450.852.camel@ecld0pohly>
	<1226415403.31699.0.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opurdila@ixiacom.com,
	shemminger@vyatta.com, netdev@axxeo.de, ak@linux.intel.com,
	john.ronciak@intel.com, dada1@cosmosbay.com, oliver@hartkopp.net
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60395
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751447AbYKLJz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 04:55:26 -0500
In-Reply-To: <1226415403.31699.0.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Wed, 22 Oct 2008 14:46:39 +0200

> In __sock_recv_timestamp() the additional SCM_TIMESTAMP[NS] is used. This
> has the same value as SO_TIMESTAMP[NS], so this is a purely cosmetic change.
> 
> Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>

I've applied this to net-2.6 as really this is a correction.

Thanks!
