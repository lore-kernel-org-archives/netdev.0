From: Ben Greear <greearb@candelatech.com>
Subject: Re: How can we bound one CPU to one Gigabit NIC?
Date: Mon, 07 Oct 2002 11:24:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DA1D15C.1070309@candelatech.com>
References: <Pine.GSO.4.30.0210070749430.1861-100000@shell.cyberus.ca> <03ab01c26e2d$06adeac0$f5f2010a@weixl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Xiaoliang (David) Wei" <weixl@caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Xiaoliang (David) Wei wrote:
> Hi Everyone,
>       I am now doing some experiments on Dual CPU (2.4Ghz) with 2 Gigabit
> cards. Can anyone tell me how to bound one CPU to each NIC so that we don't
> need to care about the packet-reordering and the interrupt sharing problems?
>       Thank you very much.:)

My experiments show you will still get re-ordered packets occasionally
(but then again, I'm having other wierd problems, so maybe you wont).

# Bind processor 2 (1<<1) to irq 11
echo 2 > /proc/irq/11/smp_affinity

# Bind processor 1 (1<<0) to irq 19
echo 1 > /proc/irq/9/smp_affinity


I will be interested to hear of your results, as I have been having
heating problems with e1000 and other problems with tg3 based nics!

Ben

> 
> 
> 
> Xiaoliang (David) Wei             Graduate Student in CS@Caltech
> http://www.cs.caltech.edu/~weixl
> ====================================================
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
