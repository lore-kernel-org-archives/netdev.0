From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: SIOCADDMULTI for unicast broken
Date: 06 Jan 2003 16:00:33 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3smw6coha.fsf@defiant.pm.waw.pl>
References: <Pine.LNX.4.44.0301032029540.29812-100000@beohost.scyld.com>
	<3E163CBB.30206@candelatech.com> <3E163E4D.5090007@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <3E163E4D.5090007@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> writes:

> No!  procfs additions are discouraged.  sysfs in 2.5.x if you _must_
> do this, but SIOCDEVPRIVATE or just flat out maintaining a kernel
> patch against a stable kernel tree would be much preferred, I think.

Still, SIOCDEVPRIVATE should _not_, in my opinion, be used for anything
but hacks.
For example, we should stop using it for configuring ethernet bridges:

net/bridge/br_device.c: if (cmd != SIOCDEVPRIVATE)
-- 
Krzysztof Halasa
Network Administrator
