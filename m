From: Gao XiaoPeng <gxp@buaa.edu.cn>
Subject: (unknown)
Date: Fri, 03 Jan 2003 16:56:28 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <0H840030YRP1S9@mail.buaa.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
Subject: 
To: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,

one of my friends wants to discuss a netfilter problem with
you! thx!

-------------------------------------------------------------
hi,
    I am a student, I think that skb has all the information 
that is needed for sending and receiving.So I get the skb 
pointer at NF_IP_POST_ROUTING, put it in a chain  organized 
by myself (I use a spinlock_t  lock to control the access of 
the chain, I named it mylock), and return NF_STOLEN. 
  I make a  tq_timer task to start ip_finish_output2(I export 
it from kernel),ip_finish_output2 use the skb from my chain.I 
can make ftp run ok for almost 1 hour, but then the system will 
carsh with this information:
 
        ds:0018    es:0018    ss:0018
        process swapper(pid:0, stackpage = c0265000)
        stack: c01a07ea c173a088 ...........
        call trace:[<c01a07ea>]    [<c01a156d>]......
        code: 0f 0b 89 7c 24 04 b8 03 00 00 00......
        <0>kernel panic: Aiee, killing interrupt handler!
        In interrupt handler - not syncing!
 
     I want to know why I count run for some time but could not 
go on for a long time . Does it possible to transmit data by the 
way and how to do?thanks very much!

best regard

Chen Wei
