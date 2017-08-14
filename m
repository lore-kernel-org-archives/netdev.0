From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/3] XDP support for tap
Date: Sun, 13 Aug 2017 19:56:49 -0700 (PDT)
Message-ID: <20170813.195649.1320361489777509765.davem@davemloft.net>
References: <1502451678-17358-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kubakici@wp.pl
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502451678-17358-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 11 Aug 2017 19:41:15 +0800

> Hi all:
> 
> This series tries to implement XDP support for tap. Two path were
> implemented:
> 
> - fast path: small & non-gso packet, For performance reason we do it
>   at page level and use build_skb() to create skb if necessary.
> - slow path: big or gso packet, we don't want to lose the capability
>   compared to generic XDP, so we export some generic xdp helpers and
>   do it after skb was created.
> 
> xdp1 shows about 41% improvement, xdp_redirect shows about 60%
> improvement.
> 
> Changes from V1:
> - fix the race between xdp set and free
> - don't hold extra refcount
> - add XDP_REDIRECT support
> 
> Please review.

Series applied, thanks Jason.
