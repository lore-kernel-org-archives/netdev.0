From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] netfilter fixes for net
Date: Mon, 17 Jun 2013 16:14:27 -0700 (PDT)
Message-ID: <20130617.161427.1465546621381589932.davem@davemloft.net>
References: <1371497679-14314-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1371497679-14314-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 17 Jun 2013 21:34:36 +0200

> The following patchset contains Netfilter fixes. They are targeted to the
> TCP option targets, that have receive some scrinity in the last week. The
> changes are:
> 
> * Fix TCPOPTSTRIP, it stopped working in the forward chain as tcp_hdr
>   uses skb->transport_header, and we cannot use that in the forwarding
>   case, from myself.
> 
> * Fix default IPv6 MSS in TCPMSS in case of absence of TCP MSS options,
>   from Phil Oester.
> 
> * Fix missing fragmentation handling again in TCPMSS, from Phil Oester.
> 
> You can pull these changes from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Pulled, thanks Pablo.
