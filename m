From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: bpf: correctly handle errors in sk_attach_filter()
Date: Sat, 13 Sep 2014 11:24:53 +0200
Message-ID: <1410600293.25850.2.camel@localhost>
References: <1410581190-31922-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@plumgrid.com, keescook@chromium.org,
	dborkman@redhat.com, spender@grsecurity.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:43925 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751780AbaIMJY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 05:24:58 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id B31DE207A1
	for <netdev@vger.kernel.org>; Sat, 13 Sep 2014 05:24:55 -0400 (EDT)
In-Reply-To: <1410581190-31922-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sa, 2014-09-13 at 00:06 -0400, Sasha Levin wrote:
> Commit "net: bpf: make eBPF interpreter images read-only" has changed bpf_prog
> to be vmalloc()ed but never handled some of the errors paths of the old code.
> 
> On error within sk_attach_filter (which userspace can easily trigger), we'd
> kfree() the vmalloc()ed memory, and leak the internal bpf_work_struct.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Yeah, thanks, we missed that somehow.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Bye,
Hannes
