From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH RESEND 01/10] netfilter: move nf_conntrack initialize
 out of pernet operations
Date: Mon, 21 Jan 2013 02:08:39 +0100
Message-ID: <20130121010839.GA26149@1984>
References: <1358504190-6094-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, ebiederm@xmission.com, canqunzhang@gmail.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39082 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752612Ab3AUBIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2013 20:08:45 -0500
Content-Disposition: inline
In-Reply-To: <1358504190-6094-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gao,

On Fri, Jan 18, 2013 at 06:16:21PM +0800, Gao feng wrote:
> Right now,the netfilter initialize and cleanup codes are
> in pernet operations function.
> This job should be done in module_init/exit.We can't use
> init_net to identify if it's the right time to initialize
> or cleanup.

nf-next$ patch -p1 < /tmp/RESEND-01-10-netfilter-move-nf_conntrack-initialize-out-of-pernet-operations.patch
patching file include/net/netfilter/nf_conntrack_core.h
patching file net/netfilter/nf_conntrack_core.c
Hunk #1 succeeded at 1334 (offset 3 lines).
Hunk #2 succeeded at 1350 (offset 3 lines).
Hunk #3 FAILED at 1368.
Hunk #4 succeeded at 1383 (offset 4 lines).
Hunk #5 succeeded at 1473 (offset 4 lines).
Hunk #6 succeeded at 1521 (offset 4 lines).
Hunk #7 succeeded at 1538 (offset 4 lines).
Hunk #8 FAILED at 1588.
Hunk #9 succeeded at 1627 (offset 12 lines).
2 out of 9 hunks FAILED -- saving rejects to file
net/netfilter/nf_conntrack_core.c.rej
patching file net/netfilter/nf_conntrack_standalone.c

What tree have you used to rebase your patches? Please, use nf-next as
base.
