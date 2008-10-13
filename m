From: David Miller <davem@davemloft.net>
Subject: Re: IPv6 mapped sockets don't work with TCP MD5
Date: Mon, 13 Oct 2008 00:33:34 -0700 (PDT)
Message-ID: <20081013.003334.16335040.davem@davemloft.net>
References: <396556a20810031531q7ae71d30q4fb7d21334e4c9b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57825
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753650AbYJMHd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 03:33:58 -0400
In-Reply-To: <396556a20810031531q7ae71d30q4fb7d21334e4c9b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Fri, 3 Oct 2008 15:31:11 -0700

> So I'm basically looking for guidance on how I should write the patch here.
> 
> 1) We could add a calc_hash function pointer to request_sock_ops and
> use that when building SYNACKs. However, request_socks aren't just
> used in TCP.
> 2) We could pass the signature function as an argument to
> tcp_make_synack since we always call it from a v4/v6 specific place
> 
> I'm learning towards the second, but whatever wiser heads suggest I'll
> implement.

I think the second variant is the best too.

Thanks for looking into this Adam.
