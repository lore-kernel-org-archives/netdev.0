From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Fix BUG When Received Unknown Protocol
Date: Thu, 21 Nov 2002 21:56:28 -0800 (PST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021121.215628.133829160.davem@redhat.com>
References: <20021121.013203.100868154.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	kuznet@ms2.inr.ac.ru.ee.t.u-tokyo.ac.jp, usagi@linux-ipv6.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021121.013203.100868154.yoshfuji@linux-ipv6.org>
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Thu, 21 Nov 2002 01:32:03 -0500 (EST)

   Since 2.5.43, kernel panics by executing BUG() when
   received unknown protocol in IPv6 packet. 
   This is because ip6_input_finish() try to kfree_skb() 
   while icmpv6_param_prob() has already kfree_skb()'ed the skb.

Patch applied, thanks.
