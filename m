From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: oops in raw_rcv_skb
Date: Fri, 1 Aug 2003 12:18:13 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0308011217520.18584@montezuma.mastecende.com>
References: <Mutt.LNX.4.44.0308020150400.29556-100000@excalibur.intercode.com.au>
 <Pine.LNX.4.53.0308011213350.18584@montezuma.mastecende.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Pine.LNX.4.53.0308011213350.18584@montezuma.mastecende.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 1 Aug 2003, Zwane Mwaikambo wrote:

> Here is a new oops with the corresponding code. 2.6.0-test2-mm2
> 
> (gdb) list *raw_rcv_skb+0x1b5
> 0xc04e2235 is in raw_rcv_skb (sock.h:942).
> 937
> 938             skb->dev = NULL;
> 939             skb_set_owner_r(skb, sk);
> 940             skb_queue_tail(&sk->sk_receive_queue, skb);
> 941             if (!sock_flag(sk, SOCK_DEAD))
> 942                     sk->sk_data_ready(sk, skb->len);
> 943     out:
> 944             return err;
> 945     }

seems to be the same bug as the previous one i posted.
