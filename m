From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: RFC: Cisco HDLC bridging
Date: Thu, 17 Jun 2004 00:49:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3zn73i0dk.fsf@defiant.pm.waw.pl>
References: <C060DFCD9697A842B3189B458524FDC205D2CD@AIMAIL1.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eble, Dan" <DanE@aiinet.com>
In-Reply-To: <C060DFCD9697A842B3189B458524FDC205D2CD@AIMAIL1.ai.aiinet.com> (Dan
 Eble's message of "Wed, 16 Jun 2004 08:58:35 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Eble, Dan" <DanE@aiinet.com> writes:

> Ah, yes.  But if the device does not have ARPHRD_ETHER the bridge driver
> will not allow it to be used as a port.

Correct. And while we can "fix" the bridge and other things, it's
still not enough.

> This is the sethdlc syntax I have chosen to create and destroy the hdlcXeth0
> device:
>
> 	sethdlc hdlc0 cisco proto <type> [ enable | disable ]
>
> Where <type> is 0x6558 for bridged ethernet packets (or maybe "ether", but I
> have not put that in yet).  I figure this will be useful to enable and
> disable other protocols too.

Ok. I'd prefer "ether", though.
-- 
Krzysztof Halasa, B*FH
