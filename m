From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: 17 Jul 2003 01:28:58 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1058394538.5778.17.camel@hades>
References: <200307151428.SAA08491@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pekka Savola <pekkas@netcore.fi>, davem@redhat.com, jmorris@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307151428.SAA08491@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alexey,

> And this silly combination is still _better_ than 6to4 address, which
> contains redundant information, which can be mixed up with real _IPv6_
> 6to4 addresses and whihc contains IPv4 address in some place which
> used to be identification of a network prefix.

While I see where you're coming from, I don't really understand what the
fuss is all about.

IMHO, the real hack is being able to specify the tunnel endpoint using a
gateway route in the first place. Whether that gateway address is
IPv4-compatible or a 6to4 address is just a minor detail. I view my
patch as a simple convenience to the user, extending a hack that already
exists.

A more "correct" way would be to specify the gateway address in the
remote address field of the point-to-point SIT interface, and live with
the fact that you need a separate SIT interface for each 6to4 gateway
that you want to tunnel to. This already works, so the IPv4-compat route
hack is actually redundant. My understanding was that it is there simply
for convenience.

	MikaL
