From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6]: Fix policy routing lookup
Date: Sun, 06 Aug 2006 22:24:30 -0700 (PDT)
Message-ID: <20060806.222430.08078279.davem@davemloft.net>
References: <44D6CD4E.60009@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28374
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751069AbWHGFYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 01:24:31 -0400
To: kaber@trash.net
In-Reply-To: <44D6CD4E.60009@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 07 Aug 2006 07:19:10 +0200

> [IPV6]: Fix policy routing lookup
>
> When the lookup in a table returns ip6_null_entry the policy routing lookup
> returns it instead of continuing in the next table, which effectively means
> it only searches the local table.
>
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Thanks for fixing this, applied.
