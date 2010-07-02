From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] nf_conntrack_reasm: add fast path for in-order fragments
Date: Fri, 02 Jul 2010 09:53:20 +0200
Message-ID: <4C2D9AF0.3030208@trash.net>
References: <1277956710-22313-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Mitchell Erblich <erblichs@earthlink.net>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1277956710-22313-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changli Gao wrote:
> nf_conntrack_reasm: add fast path for in-order fragments
>
> As the fragments are sent in order in most of OSes, such as Windows, Darwin and
> FreeBSD, it is likely the new fragments are at the end of the inet_frag_queue.
> In the fast path, we check if the skb at the end of the inet_frag_queue is the
> prev we expect.
>
>   

I'll apply this when merging with net-next the next time since this depends
on your "fragment: add fast path for in-order fragments" patch.
