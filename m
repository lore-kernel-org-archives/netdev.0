From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Fri, 10 Apr 2015 14:22:05 +0100
Message-ID: <20150410132205.GF23070@casper.infradead.org>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33969 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964850AbbDJNWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 09:22:06 -0400
Content-Disposition: inline
In-Reply-To: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/15 at 02:15pm, Pablo Neira Ayuso wrote:
> This patchset adds the Netfilter hook at the ingress path, in a per-device
> fashion. This also comes with the new nf_tables 'netdev' family support to
> provide access to users to the existing nf_tables features. This includes the
> transactional netlink API and the enhanced set infrastructure.  Several patches
> come in first place to prepare this support, including the refactoring of
> __netif_receive_skb_core() to accomodate the new hook.

Is the goal to eventually replace ebtables with this?
