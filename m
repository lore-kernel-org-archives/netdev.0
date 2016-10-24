From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 4/5] ipv6: Compute multipath hash for sent ICMP
 errors from offending packet
Date: Mon, 24 Oct 2016 11:40:39 +0200
Message-ID: <95fdee03-d595-f1fd-b10d-fc775feaef2b@stressinduktion.org>
References: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
 <1477301332-23954-5-git-send-email-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Eric Dumazet <edumazet@google.com>
To: Jakub Sitnicki <jkbs@redhat.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477301332-23954-5-git-send-email-jkbs@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24.10.2016 11:28, Jakub Sitnicki wrote:
> Improve debuggability with tools like traceroute and make PMTUD work in
> setups that make use of ECMP routing by sending ICMP errors down the
> same path as the offending packet would travel, if it was going in the
> opposite direction.
> 
> There is a caveat, flows in both directions need use the same
> label. Otherwise packets from flow in the opposite direction and ICMP
> errors will not be routed over the same ECMP link.
> 
> Export the function for calculating the multipath hash so that we can
> use it also on receive side, when forwarding ICMP errors.
> 
> Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
