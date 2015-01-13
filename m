From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: fix rx packet length check to allow
 for TSO
Date: Tue, 13 Jan 2015 17:24:36 -0500 (EST)
Message-ID: <20150113.172436.149425262485494382.davem@davemloft.net>
References: <54B559A1.9010303@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36788 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbbAMWYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 17:24:39 -0500
In-Reply-To: <54B559A1.9010303@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Tue, 13 Jan 2015 12:45:05 -0500

> This patch fixes the rx packet length check in the sunvnet driver to allow
> for a TSO max packet length greater than the LDC channel negotiated MTU.
> These are negotiated separately and there is no requirement that
> port->tsolen be less than port->rmtu, but if it isn't, it'll drop packets
> with rx length errors.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

Applied, thanks David.
