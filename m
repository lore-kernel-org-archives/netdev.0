From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: reset transport header if it was not
 set before transmission
Date: Sun, 17 Mar 2013 12:13:18 -0400 (EDT)
Message-ID: <20130317.121318.1869489921021513474.davem@davemloft.net>
References: <1363333305-54398-1-git-send-email-jasowang@redhat.com>
	<1363333305-54398-2-git-send-email-jasowang@redhat.com>
	<1363399851.29475.52.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363399851.29475.52.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Mar 2013 19:10:51 -0700

> Any way we can avoid adding this to fast path, for people not using
> macvtap and ixgbe ?

Likewise I'd rather see macvtap be responsible for fixing this up by
setting the transport header properly, and therfore sending well
formed packets to the rest of the stack.
