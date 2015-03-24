From: David Miller <davem@davemloft.net>
Subject: Re: ipv6 : Don't reduce hop limit below current value
Date: Tue, 24 Mar 2015 18:06:10 -0400 (EDT)
Message-ID: <20150324.180610.1598116015739871982.davem@davemloft.net>
References: <1427232969.3276.4.camel@takeit.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ljungmark@modio.se, spider@takeit.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbbCXWGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:06:12 -0400
In-Reply-To: <1427232969.3276.4.camel@takeit.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "D. S. Ljungmark" <spider@takeit.se>
Date: Tue, 24 Mar 2015 22:36:09 +0100

> +		/*	Only set hop_limit on the interface if it is higher than
> +		*	the current hop_limit.
> +		 */

Comments in the networking should be of the form:

	/* Like
	 * this.
	 */
