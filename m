From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 0/13] [RFC] Fix problems with IPv6 routing subtrees and source
 address selection
Date: Tue, 17 Oct 2006 02:52:19 +0300
Message-ID: <45341B33.7080801@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:47889 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422946AbWJPXwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 19:52:21 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

here are a bunch of more or less related patches having to do with fixing the IPv6 routing
subtrees and source address selection. Most of the code is a cleaned up version of what
I've written earlier for MIPL 2, where it has worked pretty well for a couple of years now.

The SCTP code, however, turned out to be messier and more difficult to fix than I had
originally thought. As I'm not that familiar with SCTP and don't really have an
opportunity to test the code I'm especially grateful for any comments regarding those
parts of the code.

I've tried to split up the changes into logical parts to help digest them. Please comment!

Regards,
Ville
