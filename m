From: ZHAO Wei <zw@netspeed-tech.com>
Subject: Re:
Date: Fri, 03 Jan 2003 18:11:59 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E1561EF.7040805@netspeed-tech.com>
References: <0H840030YRP1S9@mail.buaa.edu.cn>
Reply-To: zhaoway@public1.ptt.js.cn
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Gao XiaoPeng <gxp@buaa.edu.cn>
In-Reply-To: <0H840030YRP1S9@mail.buaa.edu.cn>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>     I am a student, I think that skb has all the information 
> that is needed for sending and receiving.So I get the skb 
> pointer at NF_IP_POST_ROUTING, put it in a chain  organized 
> by myself (I use a spinlock_t  lock to control the access of 
> the chain, I named it mylock), and return NF_STOLEN. 
>   I make a  tq_timer task to start ip_finish_output2(I export 
> it from kernel),ip_finish_output2 use the skb from my chain.I 
> can make ftp run ok for almost 1 hour, but then the system will 
> carsh with this information:
>  
>         ds:0018    es:0018    ss:0018
>         process swapper(pid:0, stackpage = c0265000)
>         stack: c01a07ea c173a088 ...........
>         call trace:[<c01a07ea>]    [<c01a156d>]......
>         code: 0f 0b 89 7c 24 04 b8 03 00 00 00......
>         <0>kernel panic: Aiee, killing interrupt handler!
>         In interrupt handler - not syncing!

You could try ksymoops to get some more info from the above. You
will get a call trace and that will reveal.
