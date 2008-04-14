From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [NET] [Patch 0/4]: Removing some redundancies in skbuff.h
Date: Mon, 14 Apr 2008 07:11:06 +0100
Message-ID: <1208153470-9847-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <skbuff_h_small_patchset>
Mime-Version: 1.0
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35085 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753083AbYDNGLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 02:11:17 -0400
Received: from gerrit.erg.abdn.ac.uk (Debian-exim@gerrit.erg.abdn.ac.uk [139.133.204.176])
	by erg.abdn.ac.uk (8.13.4/8.13.4) with ESMTP id m3E6BA4b021228
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 14 Apr 2008 07:11:12 +0100 (BST)
Received: from root by gerrit.erg.abdn.ac.uk with local (Exim 4.69)
	(envelope-from <root@gerrit.erg.abdn.ac.uk>)
	id 1JlHuI-0002ZX-5O
	for netdev@vger.kernel.org; Mon, 14 Apr 2008 07:11:10 +0100
In-Reply-To: <skbuff_h_small_patchset>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a small set of tiny patches reducing duplications in skbuff.h.

They can be seen as one single patch, but split apart it is more immediate
to see what they do.

Patch #1: Expresses __skb_dequeue     in terms of skb_peek and __skb_unlink.
Patch #2: Expresses __skb_queue_after in terms of __skb_insert. 
Patch #3: Expresses   skb_append      in terms of __skb_queue_after.
Patch #4: Expresses __skb_queue_tail  in terms of __skb_insert.

Also removed a comment 'XXX more streamlined implementation'.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

