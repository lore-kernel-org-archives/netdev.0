From: "Simon Barber" <simon@devicescape.com>
Subject: RE: Why is packet socket checked before bridge in netif_receive_skb?
Date: Tue, 26 Jul 2005 11:25:02 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F6AF020@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The odd thing is that the 'all protocols' handlers are checked before
the bridge hook, but the protocol type specific handlers are checked
after. Hence if you bind your packet socket to 'all' protocols you get
packets before bridging, but if you bind to a specific protocol you get
packets after the bridge hook.

Simon
 

-----Original Message-----
From: John W. Linville [mailto:linville@tuxdriver.com] 
Sent: Tuesday, July 26, 2005 11:19 AM
To: Simon Barber
Cc: netdev@oss.sgi.com
Subject: Re: Why is packet socket checked before bridge in
netif_receive_skb?

On Tue, Jul 26, 2005 at 11:03:17AM -0700, Simon Barber wrote:

> The protocol handlers are also used to implement packet sockets. - Why

> is the all handler checked before the bridge hook?

Perhaps so that one can look at frames entering on a specific interface
rather than the bridge as a whole?

John
--
John W. Linville
linville@tuxdriver.com
