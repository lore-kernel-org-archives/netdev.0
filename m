From: jamal <hadi@cyberus.ca>
Subject: Re: packet re-ordering on SMP machines.
Date: Tue, 27 Aug 2002 06:59:33 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0208270633130.6895-100000@shell.cyberus.ca>
References: <009701c24d54$d27304a0$f1fa010a@weixl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Ben Greear <greearb@candelatech.com>, Cheng Jin <chengjin@cs.caltech.edu>,
   Cheng Hu <chenghu@cs.caltech.edu>, Steven Low <slow@cs.caltech.edu>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Xiaoliang (David) Wei" <weixl@caltech.edu>
In-Reply-To: <009701c24d54$d27304a0$f1fa010a@weixl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




On Mon, 26 Aug 2002, Xiaoliang (David) Wei wrote:

> Hi Ben and Jamal,
>        Are you guys sure that getdayoftime per packet is a big overhead on
> Gbps connection?

We may be talking about different things;
I am talking about do_gettimeofday -- which is very expensive.
Anyone who has time could look at improving that. It is run per incoming
packet.

>        Do you compare the performance with getdayoftime per packet and
> without?

I think it would be pretty noticeable if you got rid of the
per-incoming-packet calls to do_gettimeofday

> I guess RFC 1323 specifies that each packet should have a timestamp
> (although not from getdayoftime).

In Linux, this is cleverly based on the system clock (jiffies).

cheers,
jamal
