From: cranium2003 <cranium2003@yahoo.com>
Subject: ip_forward difference in kernel 2.4 and 2.6
Date: Sun, 15 May 2005 06:39:34 -0700 (PDT)
Message-ID: <20050515133934.77383.qmail@web41423.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: net dev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,
        I check kernel 2.4.28 and 2.6.11 on lxr and
found that there is condition to check fragmnetation
required for packet in 2.4.28 ain ip_forward.c as
  if (skb->len > mtu && (ntohs(iph->frag_off) &
IP_DF))
                goto frag_needed;
But same will not be seen in 2.6.11 why? Then how 2.6
kenrel check this condition? Why its removed? Is it
addedd somewhere else?
Thanks in advance.
regards,
cranium
 


		
__________________________________ 
Do you Yahoo!? 
Read only the mail you want - Yahoo! Mail SpamGuard. 
http://promotions.yahoo.com/new_mail 
