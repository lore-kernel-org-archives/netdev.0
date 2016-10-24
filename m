From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/5] ipv6: Use multipath hash from flow info if
 available
Date: Mon, 24 Oct 2016 11:40:03 +0200
Message-ID: <7fef7f07-a025-9fa1-cf29-59ca23e244f8@stressinduktion.org>
References: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
 <1477301332-23954-4-git-send-email-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: Jakub Sitnicki <jkbs@redhat.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477301332-23954-4-git-send-email-jkbs@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24.10.2016 11:28, Jakub Sitnicki wrote:
> Allow our callers to influence the choice of ECMP link by honoring the
> hash passed together with the flow info. This will allow for special
> treatment of ICMP errors which we would like to route over the same link
> as the IP datagram that triggered the error.
> 
> Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
