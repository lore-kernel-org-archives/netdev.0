From: Akshay Kawale <linux781@gmail.com>
Subject: Re: Difference between skb_put() and skb_push()
Date: Sat, 2 Apr 2005 13:44:07 -0500
Message-ID: <72252ed0504021044e69d634@mail.gmail.com>
References: <72252ed05033021463a1f45b6@mail.gmail.com>
Reply-To: Akshay Kawale <linux781@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <72252ed05033021463a1f45b6@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I am trying to access the tot_len field in the IP Header using a
sk_buff structure inside a Netfilter hook.

I do something like:

(**skb).nh.iph->tot_len += 64

I have tried other variants of the same statement but none of them work.
I want to increment the length by 64 bytes, but it gives me an error
saying that I am trying to access an 'incomplete data type'.

Can anyone shed some light on this problem?
tot_len if of type __u16 (unsigned short int).

Thanks.

- Akshay
