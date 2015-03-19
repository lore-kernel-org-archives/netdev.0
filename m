From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rhashtable: Warn if min_size or max_size are
 not a power of two
Date: Thu, 19 Mar 2015 15:24:50 -0400 (EDT)
Message-ID: <20150319.152450.1573636653085091157.davem@davemloft.net>
References: <29119e13cd16d4a98b4ed6806bec2683943bcd5f.1426782799.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49496 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140AbbCSTYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 15:24:53 -0400
In-Reply-To: <29119e13cd16d4a98b4ed6806bec2683943bcd5f.1426782799.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 19 Mar 2015 17:34:39 +0100

> The current code correctly limits table size to the next power of two.
> This check is solely to catch programming errors.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
 ...
> +		roundup_pow_of_two(params->min_size) != params->min_size);

Please use "!is_power_of_two()", thanks.
