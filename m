From: Patrick McHardy <kaber@trash.net>
Subject: Re: ucc_geth: nf_conntrack: table full, dropping packet.
Date: Mon, 23 Mar 2009 13:15:45 +0100
Message-ID: <49C77D71.8090709@trash.net>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avorontsov@ru.mvista.com
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37229 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753922AbZCWMPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 08:15:53 -0400
In-Reply-To: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
> doing a "ping -f -l 3" on my host towards my board on linus tree as of 
> Friday results in lots of:
> nf_conntrack: table full, dropping packet.
> nf_conntrack: table full, dropping packet.
> nf_conntrack: table full, dropping packet.
> __ratelimit: 11 callbacks suppressed
> nf_conntrack: table full, dropping packet.
> nf_conntrack: table full, dropping packet.
> nf_conntrack: table full, dropping packet.
> nf_conntrack: table full, dropping packet.
> 
> for ucc_geth on a MPC832x.
> This really looks strange to me, ideas?

What does /proc/net/netfilter/nf_conntrack show?
