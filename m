From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] net: core: introduce
 skb_probe_transport_header()
Date: Wed, 27 Mar 2013 13:07:43 -0400 (EDT)
Message-ID: <20130327.130743.2174768360702998855.davem@davemloft.net>
References: <1364375482-7439-1-git-send-email-jasowang@redhat.com>
	<1364375482-7439-2-git-send-email-jasowang@redhat.com>
	<1364395550.15753.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364395550.15753.6.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Mar 2013 07:45:50 -0700

> On Wed, 2013-03-27 at 17:11 +0800, Jason Wang wrote:
>> Sometimes, we need probe and set the transport header for packets (e.g from
>> untrusted source). This patch introduces a new helper
>> skb_probe_transport_header() which tries to probe and set the l4 header through
>> skb_flow_dissect(), if not just set the transport header to the hint passed by
>> caller.
>> 
>> Cc: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  include/linux/skbuff.h |   14 ++++++++++++++
>>  1 files changed, 14 insertions(+), 0 deletions(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
