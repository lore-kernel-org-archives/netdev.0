From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net/ethernet/micrel/ks8851_mll:
 Implement basic statistics
Date: Tue, 29 Jan 2013 13:55:23 -0500 (EST)
Message-ID: <20130129.135523.2248566447781665296.davem@davemloft.net>
References: <FD9AD8C5375B924CABC56D982DB3A802079D382B@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, Ping.Doong@Micrel.Com,
	bhutchings@solarflare.com
To: David.Choi@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab3A2SzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 13:55:25 -0500
In-Reply-To: <FD9AD8C5375B924CABC56D982DB3A802079D382B@EXMB1.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Choi, David" <David.Choi@Micrel.Com>
Date: Tue, 29 Jan 2013 18:24:57 +0000

Do not post new versions of patches as replies to other emails or
threads, always use fresh, new list postings to post a patch.

> +		} else if (likely((frame_hdr->sts & RXFSHR_RXFV) &&
> +				frame_hdr->len > 0 &&
> +				frame_hdr->len <= RX_BUF_SIZE)) {

Not indented properly, if you're using purely TAB characters and no
space characters at all, chances are you're doing it wrong.

Conditionals are to be indented like this:

	if (A &&
	    B ||
	    C)

Specifically, the first character on the second and subsequent
lines must line up with the first column after the openning
parenthesis on the first line.

You must use whatever combination of TAB and space characters
are necessary to achieve this.

Several text editors, such as emacs, can be configured to do
all of this automatically for you when you press TAB.
