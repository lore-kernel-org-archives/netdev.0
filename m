From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [FYI PATCH] Ethernet over Cisco HDLC
Date: Thu, 24 Jun 2004 17:32:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3r7s57z07.fsf@defiant.pm.waw.pl>
References: <C060DFCD9697A842B3189B458524FDC205D2DE@AIMAIL1.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eble, Dan" <DanE@aiinet.com>
In-Reply-To: <C060DFCD9697A842B3189B458524FDC205D2DE@AIMAIL1.ai.aiinet.com> (Dan
 Eble's message of "Thu, 24 Jun 2004 10:24:26 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Eble, Dan" <DanE@aiinet.com> writes:

> Are you sure that is a good idea?  Using separate numbers for Cisco and FR
> is a safeguard against unwittingly creating an FR PVC with "sethdlc cisco
> proto ether ... ".  Or are you suggesting to merge the sethdlc syntax too?

Almost. FR has DLCI, Cisco HDLC doesn't. This would result in small
syntax and code differences.

I have to investigate this a little further. For 2.6 I'd go with ~ your
patch.
-- 
Krzysztof Halasa, B*FH
