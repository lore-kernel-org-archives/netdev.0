From: Steve Hill <steve@navaho.co.uk>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Tue, 3 Feb 2004 14:35:45 +0000 (GMT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402031415390.10797@sorbus2.navaho>
References: <Pine.LNX.4.33.0402030941100.11027-100000@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
In-Reply-To: <Pine.LNX.4.33.0402030941100.11027-100000@blackhole.kfki.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Feb 2004, Jozsef Kadlecsik wrote:

> I created exactly the same setup (machine 1 and 3 are UMLs) and could not
> reproduce the problem. tcpdump shows that machine 1 sends fragmented ICMP
> echo requests and machine 3 sends ICMP echo reply back. On machine 2,
> ip_conntrack_max is lowered to 10, still there is no problem after
> hundreds of pings.
> 
> Do you have any extra patch applied on the top of 2.6.2rc2?

No extra patches, it's the vanilla 2.6.2rc2 kernel.  I'm running a 
nonmodular kernel and have spent this morning recompiling it with 
different options - the problem is only showing up when CONFIG_IP_NF_NAT 
is turned on, so I'm guessing that you are using a modular kernel and 
since you haven't set up any rules in the nat table, the module isn't 
loaded - try modprobing it and seeing if that helps.


- Steve Hill
Senior Software Developer                        Email: steve@navaho.co.uk
Navaho Technologies Ltd.                           Tel: +44-870-7034015

        ... Alcohol and calculus don't mix - Don't drink and derive! ...
