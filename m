From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: bisect: bug X11 not working for SSH on net-next commit 6ae459bda
Date: Fri, 2 Oct 2015 09:52:12 +0200
Message-ID: <20151002095212.7b47869c@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Anupam Chanda <achanda@vmware.com>,
	Tom Herbert <tom@herbertland.com>,
	Andrew Vagin <avagin@odin.com>
To: David Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45478 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100AbbJBHwQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2015 03:52:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi DaveM,

Could you please merge git tree net into net-next.

Running on a kernel based on net-next (at commit 4bf1b54f9df) made my
SSH stopped forwarding X11.

Bisected the problem down to commit 6ae459bda ("skbuff: Fix skb
checksum flag on skb pull"), which seems to have been fixed in git
tree "net" by commit 31b33dfb0a14 ("skbuff: Fix skb checksum partial
check.").

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

keywords: X11 SSH csum checksum bug IPv6 connect error loopback broken
