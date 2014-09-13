From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: bpf: correctly handle errors in sk_attach_filter()
Date: Sat, 13 Sep 2014 11:12:39 +0200
Message-ID: <54140A87.603@redhat.com>
References: <1410581190-31922-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@plumgrid.com, keescook@chromium.org,
	hannes@stressinduktion.org, spender@grsecurity.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13124 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879AbaIMJNG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2014 05:13:06 -0400
In-Reply-To: <1410581190-31922-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/13/2014 06:06 AM, Sasha Levin wrote:
> Commit "net: bpf: make eBPF interpreter images read-only" has changed bpf_prog
> to be vmalloc()ed but never handled some of the errors paths of the old code.
>
> On error within sk_attach_filter (which userspace can easily trigger), we'd
> kfree() the vmalloc()ed memory, and leak the internal bpf_work_struct.
>
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

[ This patch is for net-next. ]

Acked-by: Daniel Borkmann <dborkman@redhat.com>
