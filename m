From: jamal <hadi@cyberus.ca>
Subject: Re: Update on e1000 troubles (over-heating!)
Date: Sun, 6 Oct 2002 18:38:32 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210061835350.1861-100000@shell.cyberus.ca>
References: <Pine.LNX.4.10.10210052045090.22517-100000@master.linux-ide.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Greear <greearb@candelatech.com>,
   linux-kernel <linux-kernel@vger.kernel.org>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andre Hedrick <andre@pyxtechnologies.com>
In-Reply-To: <Pine.LNX.4.10.10210052045090.22517-100000@master.linux-ide.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 5 Oct 2002, Andre Hedrick wrote:

>
> I have a pair of Compaq e1000's which have never overheated, and I use
> them for heavy duty iSCSI testing and designing of drivers.  These are
> massive 66/64 cards but still nothing like what you are reporting.
>
> I will look some more at the issue soon.
>

It seems like the prerequisite to reproduce it is you beat the NIC heavily
with a lot of packets/sec and then run it at that sustained rate for at
least 30 minutes. isci would tend to use MTU sized packets which will
not be that effective.

cheers,
jamal
