From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: Kernel BUG: Qos seg. fault
Date: Mon, 24 May 2004 14:53:46 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524215346.73109.qmail@web80501.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jaume Catarineu <jaume.catarineu@upf.edu>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > Since TBF has only one child no matter what I contend that
> > implementing filters for TBF does not make sense, filters should
> > be attached either to TBF's child ot to TBF's parent but not to
> > TBF itself.
> 
> Ok, understood. Why does TBF have only one child?

It just does... TBF as far as I understand is a simple rate
limiting tool for your network link. I implemented the child
qdisc for TBF so you can change default fifo queue in it to
SFQ or PRIO. It supposed to be very lightweight. If you need
something more complex/fancy then you probably want HTB or CBF.

It's all just my opinion though.

Dmitry
