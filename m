From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make hmac algorithm selection for cookie generation
 dynamic
Date: Tue, 23 Oct 2012 02:32:54 -0400 (EDT)
Message-ID: <20121023.023254.1960160564751660622.davem@davemloft.net>
References: <1350661926-8312-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452Ab2JWGc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 02:32:56 -0400
In-Reply-To: <1350661926-8312-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 19 Oct 2012 11:52:06 -0400

> Currently sctp allows for the optional use of md5 of sha1 hmac algorithms to
> generate cookie values when establishing new connections via two build time
> config options.  Theres no real reason to make this a static selection.  We can
> add a sysctl that allows for the dynamic selection of these algorithms at run
> time, with the default value determined by the corresponding crypto library
> config options.  It saves us two needless configuration settings and enables the
> freedom for administrators to select which algorithm a particular system uses.
> This comes in handy when, for example running a system in FIPS mode, where use
> of md5 is disallowed, but SHA1 is permitted.
> 
> Note: This new sysctl has no corresponding socket option to select the cookie
> hmac algorithm.  I chose not to implement that intentionally, as RFC 6458
> contains no option for this value, and I opted not to pollute the socket option
> namespace.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Neil, please use appropriate subject prefixes in your patch
submissions.  In this case "sctp: " would have been appropriate.

Vlad, this patch looks fine to me, but I'd like you to review
it too before I apply it.

Thanks.
