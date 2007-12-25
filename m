From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net: santize headers for iproute2
Date: Tue, 25 Dec 2007 12:43:23 -0800
Message-ID: <20071225124323.70e0c772@deepthought>
References: <20071221094336.63600b8c@deepthought>
	<20071224.220527.254578945.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57765 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066AbXLYUoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 15:44:54 -0500
In-Reply-To: <20071224.220527.254578945.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> net/tcp_states.h is not movable to include/linux/ and thus to
> userspace, it defines things that are present already in existing
> userland header files.  If you look, <netinet/tcp.h> defines these
> state values, as an enumeration.  If you need the TCPF_* flag bit
> versions, sorry... you'll need to find some other way to get those
> into userspace.

The problem is that iproute ss.c needs linux/tcp.h to get the tcp_info
structure definition but linux/tcp.h has incompatible definitions with netinet/tcp.h. 
I propose that the enum be moved from net/tcp_states.h to linux/tcp.h.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
