From: jamal <hadi@cyberus.ca>
Subject: Re: Limited Transmit
Date: Tue, 27 Aug 2002 07:18:41 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0208270712210.6895-100000@shell.cyberus.ca>
References: <88BC9E379956AE4DB689CC5FF6F5A43D2970AB@exchange.Ic4ic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Naim Far <naim@Ic4ic.com>
In-Reply-To: <88BC9E379956AE4DB689CC5FF6F5A43D2970AB@exchange.Ic4ic.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




On Tue, 27 Aug 2002, Naim Far wrote:

> How do I add the "Limited Trasnmit" (RFC 3042) feature to the TCP
> implementation in Linux ?
>

I am not sure if this RFC will add a lot of value if any to Linux.
Linux already knows how to to undo changes that are caused by false
alarms like reordering.
To implement start with linux/net/ipv4/* and look at the tcp files.

cheers,
jamal
