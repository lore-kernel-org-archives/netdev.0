From: kuznet@ms2.inr.ac.ru
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Wed, 16 Jul 2003 03:19:00 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307152319.DAA09683@dub.inr.ac.ru>
References: <Pine.LNX.4.44.0307152025570.14070-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi (Pekka Savola)
In-Reply-To: <Pine.LNX.4.44.0307152025570.14070-100000@netcore.fi> from "Pekka Savola" at éÀÌ 15, 2003 08:29:11 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Assume you're a host on a link with prefix 3FFE:FFFF:A:B::/64.  The router 
> is the one with interface ID one.

Not going to work. Host autoconfiguration conventions have nothing
to do with real addressing. Proceeding in this way you will denounce
neighbour discovery, what the hell to do this when hw address can be recovered
from EUI64 token? :-)


> What happens when you do "ping6 3FFE:FFFF:A:B::1" ?

Hey, you have lost track, rewind several mails ago. Of course, ping and
any other protocols will work, how can it not work? :-)

Alexey
