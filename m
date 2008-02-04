From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-mm1 - Build failure at net/sched/cls_flow.c:598
Date: Mon, 4 Feb 2008 15:25:05 -0800
Message-ID: <20080204152505.62b2b8b5.akpm@linux-foundation.org>
References: <20080203171634.58ab668b.akpm@linux-foundation.org>
	<47A79291.5010204@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60461 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754748AbYBDXZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 18:25:16 -0500
In-Reply-To: <47A79291.5010204@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 04 Feb 2008 23:32:49 +0100
Tilman Schmidt <tilman@imap.cc> wrote:

> My attempt to build this failed with:
> 
>    CC [M]  net/sched/cls_flow.o
> net/sched/cls_flow.c: In function ___flow_dump___:
> net/sched/cls_flow.c:598: error: ___struct tcf_ematch_tree___ has no member named ___hdr___
> 
> Config attached.

Thanks.  hm.

	#else /* CONFIG_NET_EMATCH */

	struct tcf_ematch_tree
	{
	};

methinks Patrick has a CONFIG_NET_EMATCH=n problem?
