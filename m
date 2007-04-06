From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH 0/4] [IPv6] Add new scope and address type inlines
Date: Thu, 05 Apr 2007 23:19:25 -0400
Message-ID: <4615BC3D.8010803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:34153 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767521AbXDFDmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 23:42:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[sorry if anyone got these multiple times, git-send-email weirdness]

This set of patches adds new IPv6 scope and address type inlines
to both clean-up the code (inspired by Arnaldo's skb cleanup) and reduce
calls to ipv6_addr_type() when we can just compare the address directly.
No functionality is changed.

I'm only cc'ing the DCCP and LkSCTP lists on the patches that actually
touch their code.

-Brian

