From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/7] SCTP updates for net-next-2.6
Date: Tue, 26 Apr 2011 14:51:20 -0700 (PDT)
Message-ID: <20110426.145120.28826019.davem@davemloft.net>
References: <4DB63F85.2090609@cn.fujitsu.com>
	<20110426.001238.183056292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38145
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756552Ab1DZVvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 17:51:53 -0400
In-Reply-To: <20110426.001238.183056292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Wei, while you are re-spinning this patch set I want to bring up
something I just noticed in the SCTP code.

The ->dst_saddr() method is not used by anything, it appears.

The ipv4 variant, sctp_v4_dst_saddr() is called internally by the
ipv4 specific code, but that's it.

So I think the ->dst_saddr member of sctp_pf can be completely
removed, as can sctp_v6_dst_saddr().

The sctp_v4_dst_saddr() function, of course, will need to be retained.
