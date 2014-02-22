From: Florian Westphal <fw@strlen.de>
Subject: [PATCH stable 3.10.y 0/3] gso/gro forwarding changeset
Date: Sat, 22 Feb 2014 10:30:16 +0100
Message-ID: <1393061419-4892-1-git-send-email-fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44027 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751072AbaBVJeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 04:34:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3.10 does not aggregate ~DF packets via GRO.  However, as
Marcelo Leitner pointed out to me we can still encounter GSO packets in
fwd path in virtual environments where we receive GSO packet eg. via virtio.

Let me know if there are problems.
