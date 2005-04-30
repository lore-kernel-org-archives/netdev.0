From: linux lover <linux_lover2004@yahoo.com>
Subject: why memory is wasted in skbuff for received packet skb_alloc?
Date: Sat, 30 Apr 2005 04:27:10 -0700 (PDT)
Message-ID: <20050430112711.91741.qmail@web52207.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,
          In kernel 2.4.30 i observe that when my
ethernet card received packet and uses alloc_skb its
not placing all pointers skb->data,skb->head,skb->tail
to same starting location instead i found it places
skb->data and skb->tail have 10 locations more than
skb->head.
          For what purpose this 10 bytes are reserved
in skbuff also i am not able to see that skb_reserve
as theres no call to skb_reserve and i am printing
skbuff pointer values just after it gets allocated by
alloc_skb.

Thanks in advance,
linux_lover

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
