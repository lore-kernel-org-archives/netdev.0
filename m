From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: beet: fix pseudo header length value
Date: Mon, 23 Apr 2007 22:39:27 -0700 (PDT)
Message-ID: <20070423.223927.98861952.davem@davemloft.net>
References: <462C98E9.4020504@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Diego.Beltrami@hiit.fi, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45819
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161637AbXDXFjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 01:39:20 -0400
In-Reply-To: <462C98E9.4020504@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 23 Apr 2007 13:30:49 +0200

> [XFRM]: beet: fix pseudo header length value
> 
> draft-nikander-esp-beet-mode-07.txt is not entirely clear on how the length
> value of the pseudo header should be calculated, it states "The Header Length
> field contains the length of the pseudo header, IPv4 options, and padding in
> 8 octets units.", but also states "Length in octets (Header Len + 1) * 8".
> draft-nikander-esp-beet-mode-08-pre1.txt [1] clarifies this, the header length
> should not include the first 8 byte.
> 
> This change affects backwards compatibility, but option encapsulation didn't
> work until very recently anyway.
> 
> [1] http://users.piuha.net/jmelen/BEET/draft-nikander-esp-beet-mode-08-pre1.txt
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.

More fun rejects for the next net-2.6.22 rebase :-)))
