From: "Simon Barber" <simon@devicescape.com>
Subject: RE: Why is packet socket checked before bridge in netif_receive_skb?
Date: Tue, 2 Aug 2005 11:30:40 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F776D30@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ah - OK, so I guess it is an artifact of the reuse of the protocol
handler structures that means that some packet sockets see frames before
the bridge and others after. I guess this doesn't cause any problems.

Simon


-----Original Message-----
From: David S. Miller [mailto:davem@davemloft.net] 
Sent: Tuesday, July 26, 2005 12:59 PM
To: Simon Barber
Cc: netdev@oss.sgi.com
Subject: Re: Why is packet socket checked before bridge in
netif_receive_skb?

From: "Simon Barber" <simon@devicescape.com>
Subject: Why is packet socket checked before bridge in
netif_receive_skb?
Date: Tue, 26 Jul 2005 11:03:17 -0700

> The protocol handlers are also used to implement packet sockets. - Why
> is the all handler checked before the bridge hook?

Because we want packet sniffers to see the packet before the
bridging layer decapsulates it.
