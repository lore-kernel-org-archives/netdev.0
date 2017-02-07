From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v4 net] bpf: add bpf_sk_netns_id() helper
Date: Tue, 07 Feb 2017 11:41:40 +0100
Message-ID: <5899A464.8080508@iogearbox.net>
References: <1486432968-3255218-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>, Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37924 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753268AbdBGKlu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 05:41:50 -0500
In-Reply-To: <1486432968-3255218-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2017 03:02 AM, Alexei Starovoitov wrote:
> in cases where bpf programs are looking at sockets and packets
> that belong to different netns, it could be useful to get an id
> that uniquely identify a netns within the whole system.
>
> Therefore introduce 'u64 bpf_sk_netns_id(sk);' helper. It returns
> unique value that identifies netns of given socket or dev_net(skb->dev)
> The upper 32-bits of the return value contain device id where namespace
> filesystem resides and lower 32-bits contain inode number within that filesystem.
[...]
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Reviewed-by: David Ahern <dsa@cumulusnetworks.com>
> Tested-by: David Ahern <dsa@cumulusnetworks.com>

For the BPF bits:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
