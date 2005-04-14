From: "rahul N." <rahul8143@gmail.com>
Subject: packet forwarding understandings
Date: Thu, 14 Apr 2005 19:16:56 +0530
Message-ID: <d8d7db9905041406465f294834@mail.gmail.com>
Reply-To: "rahul N." <rahul8143@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,
 Following is code snippet from ip_forward function from ip_forward.c
........
  dev2 = rt->u.dst.dev;
        mtu = rt->u.dst.pmtu;

        /*
         *      We now generate an ICMP HOST REDIRECT giving the route
         *      we calculated.
         */
        if (rt->rt_flags&RTCF_DOREDIRECT && !opt->srr)
                ip_rt_send_redirect(skb);

        /* We are about to mangle packet. Copy it! */
        if (skb_cow(skb, dev2->hard_header_len))
                goto drop;
        iph = skb->nh.iph;
 ...............

 when router takes packet to forward does above code is written to check if
next dst hop has different network device or if it is using different
hard_header_len
so that skb_cow is called?
 whats use of skb_cow in ip_forward?
 I am using 2.4 series kernel.

regards,
rahul
