From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 5/6] netns ct: per-netns	net.netfilter.nf_conntrack_log_invalid
 sysctl
Date: Thu, 02 Oct 2008 10:04:01 +0200
Message-ID: <48E48071.4060207@trash.net>
References: <48C01046.2070704@trash.net> <1220842990-30500-17-git-send-email-adobriyan@gmail.com> <48C623CA.9060803@trash.net> <20080909073245.GA7307@x200.localdomain> <48C62B1C.7070104@trash.net> <20080913105319.GF7440@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080913105319.GF7440@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
>
>  include/net/netfilter/nf_conntrack_l4proto.h   |   15 +++++++--------
>  include/net/netns/conntrack.h                  |    1 +
>  net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
>  net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    6 +++---
>  net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
>  net/netfilter/nf_conntrack_core.c              |    1 -
>  net/netfilter/nf_conntrack_proto_dccp.c        |   10 ++++++----
>  net/netfilter/nf_conntrack_proto_tcp.c         |   18 ++++++++++--------
>  net/netfilter/nf_conntrack_proto_udp.c         |    6 +++---
>  net/netfilter/nf_conntrack_proto_udplite.c     |    8 ++++----
>  net/netfilter/nf_conntrack_standalone.c        |    6 +++---
>  11 files changed, 39 insertions(+), 36 deletions(-)
Applied.

