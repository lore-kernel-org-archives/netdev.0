From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: IPv6 IPsec input
Date: Tue, 04 Dec 2007 12:39:43 +0900
Message-ID: <4754CBFF.3000308@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:40386 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751326AbXLDDpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 22:45:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Herbert,

We have a trouble of IPv6 IPsec input process with your net-2.6.25 tree.
We can not receive IPsec packets.

I found that you directly pass the address family (AF_INET) to xfrm_state_lookup
in xfrm_input.

I guess it may result the bug.

Is it correct?

Best regards,

--
Kazunori Miyazawa


