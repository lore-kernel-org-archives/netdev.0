From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Tue, 3 Feb 2004 16:32:42 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0402031629150.11737-100000@blackhole.kfki.hu>
References: <Pine.LNX.4.58.0402031415390.10797@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Hill <steve@navaho.co.uk>
In-Reply-To: <Pine.LNX.4.58.0402031415390.10797@sorbus2.navaho>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Feb 2004, Steve Hill wrote:

> No extra patches, it's the vanilla 2.6.2rc2 kernel.  I'm running a
> nonmodular kernel and have spent this morning recompiling it with
> different options - the problem is only showing up when CONFIG_IP_NF_NAT
> is turned on, so I'm guessing that you are using a modular kernel and
> since you haven't set up any rules in the nat table, the module isn't
> loaded - try modprobing it and seeing if that helps.

I can confirm that with the NAT module loaded in, the leak you described
appears. As if the reference counts created as refragging the packet
would not be cleaned up properly...

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@sunserv.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
