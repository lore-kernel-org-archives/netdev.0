From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Sun, 10 Feb 2013 00:50:02 +0900
Message-ID: <5116702A.5000003@linux-ipv6.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <5112759E.90104@linux-ipv6.org> <20130206165415.GB19537@order.stressinduktion.org> <20130209121005.GB23281@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
To: hannes@stressinduktion.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:57868 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760747Ab3BIPuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 10:50:04 -0500
In-Reply-To: <20130209121005.GB23281@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:

> c) I will send a patch as soon as the errata thing is resolved to drop
> ff00::/15 from entering the host from the wire. In case of outgoing
> traffic to ff00::/16, should this be stopped with a net-unreachable route?

No, check should placed around ipv6_addr_loopback(), like you have
posted.  Would you cook a patch for ffx0::/16 anyway, please?

--yoshfuji
