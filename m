From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: Interfamily support for IPSEC BEET
Date: Fri, 19 Oct 2007 16:33:08 -0700 (PDT)
Message-ID: <20071019.163308.80858795.davem@davemloft.net>
References: <200710191307.55589.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: joakim.koskela@hiit.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55185
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759366AbXJSXcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 19:32:55 -0400
In-Reply-To: <200710191307.55589.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please fix up these whitespace errors in your patch, thank you:

+ git apply --check --whitespace=error-all diff
Space in indent is followed by a tab.
diff:329: 		if (x->sel.family == AF_INET) {
Space in indent is followed by a tab.
diff:330: 			x->props.header_len += IPV4_BEET_PHMAXLEN +
Space in indent is followed by a tab.
diff:331: 				(sizeof(struct ipv6hdr) - sizeof(struct iphdr));
Space in indent is followed by a tab.
diff:332: 		}
Space in indent is followed by a tab.
diff:347: 		    (x->props.mode != XFRM_MODE_BEET ||
Space in indent is followed by a tab.
diff:348: 		     x->sel.family != AF_INET6)) {
fatal: 6 lines add whitespace errors.
