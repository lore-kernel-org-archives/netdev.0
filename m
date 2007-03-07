From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: netlink regression (since 2.6.18)
Date: Wed, 7 Mar 2007 14:28:30 -0800
Message-ID: <20070307142830.307979e6@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34849 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992664AbXCGWbp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 17:31:45 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On a Ubuntu x86_64 machine the command: 
  tc qdisc ls
gets a RTNETLINK error. It looks like some data structure alignment
issue got introduced between 2.6.18 and 2.6.19-rc1 and continues on. 
Since netlink data structure layout is part of the user ABI, we need to go back
and keep compatibility.

Still working out the bisect to find where the problem started.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
