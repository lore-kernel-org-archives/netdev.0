From: "Eble, Dan" <DanE@aiinet.com>
Subject: RE: [FYI PATCH] Ethernet over Cisco HDLC
Date: Thu, 24 Jun 2004 10:24:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C060DFCD9697A842B3189B458524FDC205D2DE@AIMAIL1.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Krzysztof Halasa'" <khc@pm.waw.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I wonder if we could merge IF_PROTO_FR_(ADD|DEL)_* and 
> IF_PROTO_CISCO_*?
> It would get us the same sethdlc syntax and similar add/del code.
> -- 
> Krzysztof Halasa, B*FH

Are you sure that is a good idea?  Using separate numbers for Cisco and FR
is a safeguard against unwittingly creating an FR PVC with "sethdlc cisco
proto ether ... ".  Or are you suggesting to merge the sethdlc syntax too?
