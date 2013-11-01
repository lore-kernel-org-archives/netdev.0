From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: flow_dissector: fail on evil iph->ihl
Date: Fri, 01 Nov 2013 02:48:24 -0700
Message-ID: <1383299304.19864.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383289270-18952-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Petr Matousek <pmatouse@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383289270-18952-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-11-01 at 15:01 +0800, Jason Wang wrote:
> We don't validate iph->ihl which may lead a dead loop if we meet a IPIP
> skb whose iph->ihl is zero. Fix this by failing immediately when iph->ihl
> is evil (less than 5).
> 
> This issue were introduced by commit ec5efe7946280d1e84603389a1030ccec0a767ae
> (rps: support IPIP encapsulation).
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Petr Matousek <pmatouse@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> This patch is needed for stable.
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Jason !
