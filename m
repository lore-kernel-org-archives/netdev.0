From: "panemade" <panemade@indiatimes.com>
Subject: Re: Re: HELP ipt_hook: happy cracking message
Date: Fri, 30 Apr 2004 13:05:07 +0530
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200404300701.MAA22398@WS0005.indiatimes.com>
Reply-To: "panemade" <panemade@indiatimes.com>
Content-Type: text/plain; charset=us-ascii
Cc: "kernerl mail" <linux-kernel@vger.kernel.org>,
	<netdev@oss.sgi.com>, <linux-net@vger.kernel.org>,
	"netfilter" <netfilter-devel@lists.netfilter.org>,
	<linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "Rusty Russell" <rusty@rustcorp.com.au>
List-Id: netdev.vger.kernel.org


hello,
Because of i increase icmp header by 8 bytes the next layer IP headers are not
fully added to skbuff that is they become short and i am repeatedly getting
ip_hook : happy cracking message
so where can i modify the total size of alloc_skb to satisfy my constraints
for icmp header?
i got one reference mail that some person has done adding his own header to
ping packet and send it to other machine.he actually added that successfully.
i am unable to contact him. might be his email address has been changed.
regards,
parag.

"Rusty Russell"<rusty@rustcorp.com.au> wrote:
On Tue, 2004-04-27 at 01:12, Parag Nemade wrote:
> hi,
>         i modified kernel so that it will create
> /proc/net/myproc file entry.
> the function of this entry is to crate a 16 byte char
> string from random no.s
> i used net_srandom and net_random and sys_time for
> that puspose. the problem is that i write program to
> generate string after 120 seconds but it is changing
> contents of myproc file every seconds. what can i do?
>  Also i am getting ipt_hook: happy cracking. message
> again and again why?

You're sending out IP packets which don't even contain the IP header,
and you're running connection tracking or some filtering.

The message is not serious.

Rusty.
-- 
Anyone who quotes me in their signature is an idiot -- Rusty Russell

-
To unsubscribe from this list: send the line "unsubscribe linux-net" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Get Your Private, Free E-mail from Indiatimes at http://email.indiatimes.com

 Buy The Best In BOOKS at http://www.bestsellers.indiatimes.com

Bid for for Air Tickets @ Re.1 on Air Sahara Flights. Just log on to http://airsahara.indiatimes.com and Bid Now!

