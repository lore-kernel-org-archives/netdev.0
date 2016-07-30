From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/3] netfilter: nat: update hash bucket if nat changed
 after ct confirmed
Date: Sun, 31 Jul 2016 00:28:02 +0200
Message-ID: <20160730222802.GD29291@breakpoint.cc>
References: <1469915614-16800-1-git-send-email-xfan@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, Xiaoping Fan <xfan@codeaurora.org>
To: fxp2001640163@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:42230 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751545AbcG3Wpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 18:45:31 -0400
Content-Disposition: inline
In-Reply-To: <1469915614-16800-1-git-send-email-xfan@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fxp2001640163@gmail.com <fxp2001640163@gmail.com> wrote:
> From: Xiaoping Fan <xfan@codeaurora.org>
> 
> In some situations, NAT information is created after connection is
> confirmed.

That sounds like a bug.

How can this happen?

nf_nat_setup_info() is only safe for non-confirmed conntracks
(not in hash table).
