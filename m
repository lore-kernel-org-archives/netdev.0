From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH rfc] netfilter: two xtables matches
Date: Wed,  5 Dec 2012 14:22:17 -0500
Message-ID: <1354735339-13402-1-git-send-email-willemb@google.com>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	edumazet@google.com, davem@davemloft.net, kaber@trash.net,
	pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The second patch is more speculative and aims to be a more general
workaround, as well as a performance optimization: support
(preferably JIT compiled) BPF programs as iptables match rules.

Potentially, the skb->priority match can be implemented by applying
only the second patch and adding a new BPF_S_ANC ancillary field to
Linux Socket Filters.

I also wrote corresponding userspace patches to iptables. The process
for submitting both kernel and user patches is not 100% clear to me.
Sending the kernel bits to both netdev and netfilter-devel for
initial feedback. Please correct me if you want it another way.

The patches apply to net-next.

