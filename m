From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Tue, 3 Feb 2004 09:48:55 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0402030941100.11027-100000@blackhole.kfki.hu>
References: <Pine.LNX.4.58.0402021039540.5347@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Hill <steve@navaho.co.uk>
In-Reply-To: <Pine.LNX.4.58.0402021039540.5347@sorbus2.navaho>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Feb 2004, Steve Hill wrote:

> Just to confirm, you have your network set up like:
>
>     [ Machine 1 ]----[ Machine 2 ]----[Machine 3]
>
> Machines 1 and 3 are running the 2.4 kernel for me, but that shouldn't be
> important.
> Machine 2 is running 2.6.2rc2.

I created exactly the same setup (machine 1 and 3 are UMLs) and could not
reproduce the problem. tcpdump shows that machine 1 sends fragmented ICMP
echo requests and machine 3 sends ICMP echo reply back. On machine 2,
ip_conntrack_max is lowered to 10, still there is no problem after
hundreds of pings.

Do you have any extra patch applied on the top of 2.6.2rc2?

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@sunserv.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
