From: linux lover <linux_lover2004@yahoo.com>
Subject: how ip header added in ip_bulid_xmit function?
Date: Mon, 17 May 2004 23:31:06 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040518063106.85290.qmail@web90102.mail.scd.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@oss.sgi.com>,
	netfilter <netfilter-devel@lists.netfilter.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: linuxnet <linux-net@vger.kernel.org>
List-Id: netdev.vger.kernel.org

hello ,
   In ip_output.c file there is ip_build_xmit function
call. when packet comes from tcp layer to IP layer
this function is called. In that i found that 
   skb = sock_alloc_send_skb(sk, length+hh_len+15
,flags&MSG_DONTWAIT, &err);
staement allocates skb for packet. after that i found
that no iphdr adding statement in ip_build_xmit. i
want to know where is iphdr push to skb? cause skb
works using first alloc_skb to allocate memory then
skb_reserve to reserve headroom then put data in skb
by skb_put or skb_push for pushing headers in skb. so
there i found       
  skb->nh.iph = iph = (struct iphdr *)skb_put(skb,
length); 
statement is this does that iphdr adding?

regards,
linuxlover


	
		
__________________________________
Do you Yahoo!?
SBC Yahoo! - Internet access at a great low price.
http://promo.yahoo.com/sbc/
