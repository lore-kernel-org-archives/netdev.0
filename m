From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/9] IPv6/DCCP: fix memory leak in dccp_v6_do_rcv()
Date: Fri, 20 Oct 2006 19:25:08 -0700 (PDT)
Message-ID: <20061020.192508.38711169.davem@davemloft.net>
References: <200610202143.k9KLh25B003765@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesper.juhl@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28308
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S2992785AbWJUCZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 22:25:07 -0400
To: akpm@osdl.org
In-Reply-To: <200610202143.k9KLh25B003765@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Fri, 20 Oct 2006 14:43:02 -0700

> (akpm: does opt_skb actually do anything?)

This is a clone of similar code in net/ipv6/tcp_ipv6.c, it's just
missing the bits at label "ipv6_pktoptions:" :-)

No offence to the original patch, it's correct, but I'm going to fix
this by making the dccp ipv6 logic match the code it was copied from
in tcp_ipv6.c as much as possible.

Thanks a lot for finding this leak Jesper.
