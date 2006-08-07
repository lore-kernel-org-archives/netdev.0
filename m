From: Stephen Hemminger <shemminger@osdl.org>
Subject: Excess use of packed attribute
Date: Mon, 7 Aug 2006 13:34:23 -0700
Message-ID: <20060807133423.11bfbff3@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63418 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932345AbWHGUeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 16:34:25 -0400
To: Roland Dreier <rdreier@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After reading:
	http://bugzilla.kernel.org/show_bug.cgi?id=6693

I noticed there were stupid uses of packed attribute in several network headers.

Silly offenders:	include/net/ipx.h
			include/net/ieee80211.h
			include/net/ip6_tunnel.h
			include/net/ndisc.h
			include/linux/if_ether.h
			include/linux/if_fddi.h
		
			include/linux/sctp.h -- really bad
		
-- 
