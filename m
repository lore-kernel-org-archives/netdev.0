From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] cgroup, bpf: remove unnecessary #include
Date: Tue, 29 Nov 2016 11:48:32 +0100
Message-ID: <583D5D00.4070101@iogearbox.net>
References: <1480145027-3524392-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@zonque.org>, Tejun Heo <tj@kernel.org>,
        netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35071 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757124AbcK2Ksj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 05:48:39 -0500
In-Reply-To: <1480145027-3524392-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2016 08:23 AM, Alexei Starovoitov wrote:
> this #include is unnecessary and brings whole set of
> other headers into cgroup-defs.h. Remove it.
>
> Fixes: 3007098494be ("cgroup: add support for eBPF programs")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

This fixes many build errors in samples/bpf/ due to wrong helper
redefinitions (originating from kernel includes conflicting with
samples' helper declarations).

I don't see it pushed out to net-next yet, so:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
