From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: how to interpret C statement?
Date: Tue, 8 Jun 2004 23:41:06 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406082341.06598.vkondra@mail.ru>
References: <20040608154412.14868.qmail@web52208.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20040608154412.14868.qmail@web52208.mail.yahoo.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Easy. skb-cb used to keep struct tcp_skb_cb. Statement in your question do 
casting and return pointer to the structure.

On Tuesday 08 June 2004 18:44, linux lover wrote:
> how to interpret following C statement?
> #define TCP_SKB_CB(__skb)       ((struct tcp_skb_cb *)&((__skb)->cb[0]))
> what is use of tcp_skb_cb structure in kernel source tcp.h? how
> TCP_SKB_CB(skb) is translated in its definition? regards,
> linux_lover
>
>
>
>
>
>
> ---------------------------------
> Do you Yahoo!?
> Friends.  Fun. Try the all-new Yahoo! Messenger
