From: linux lover <linux_lover2004@yahoo.com>
Subject: tracing calls of output(skb)
Date: Mon, 17 May 2004 23:28:57 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040518062857.80216.qmail@web90109.mail.scd.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@oss.sgi.com>,
        netfilter <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: linuxkernel <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello friends,
          can anybody knows where does this
skb->dst->output(skb) call goes? it is written in
output_maybe_reroute function call in ip_output.c?
also let me know whether following two calls also
point to same destination funcaion as above function?
   hh->hh_output(skb);
   return dst->neighbour->output(skb);
if yes to which function they point (dev_queue_xmit)?

Thanking you.
linux_lover





	
		
__________________________________
Do you Yahoo!?
SBC Yahoo! - Internet access at a great low price.
http://promo.yahoo.com/sbc/
