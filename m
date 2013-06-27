From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG]: missing shinfo with netlink_alloc_large_skb
Date: Thu, 27 Jun 2013 04:50:18 -0700
Message-ID: <1372333818.3301.226.camel@edumazet-glaptop>
References: <20130627114432.GA22103@cpv436-motbuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Artem Savkov <artem.savkov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130627114432.GA22103@cpv436-motbuntu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-27 at 15:44 +0400, Artem Savkov wrote:
> Hello,
> 
> I ran into a bug while running trinity with write/writev syscalls. Seems like
> it has been introduced by "netlink: allow large data transfers from user-space"
> commit. nf_fib_input calls skb_clone which expects skb_shinfo to be allocated,
> but netlink_alloc_large_skb doesn't do that, should it?.
> Relevant dmesg log below.
> 

Yes, this was discussed and Pablo is working on it

http://marc.info/?l=linux-netdev&m=137232186620827&w=2
