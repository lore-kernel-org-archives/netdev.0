From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 -next 0/3] tcp: honour SO_BINDTODEVICE for TW_RST case too
Date: Mon, 21 Dec 2015 21:29:23 +0100
Message-ID: <1450729766-14926-1-git-send-email-fw@strlen.de>
Cc: eric.dumazet@gmail.com
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:45111 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751253AbbLUUfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 15:35:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is V2, this time as a small series since I followed Erics advice
to split this into smaller chunks, I hope this makes it easier to
review.

First patch adds inet_sk_transparent helper.
Second patch contains an if/else swap that I split from the
original TW_RST v1 one.
Third patch is the actual change without the superfluous sock_net change.

Thanks,
Florian
