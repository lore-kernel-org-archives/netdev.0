From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Device operative state notification against 2.5.7
Date: Sun, 7 Apr 2002 16:26:53 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204071623470.12041-100000@shell.cyberus.ca>
References: <Pine.GSO.4.30.0204071538220.12041-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <Pine.GSO.4.30.0204071538220.12041-100000@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org



On Sun, 7 Apr 2002, jamal wrote:

> The only useful state transitions are to/from IFOP_DOWN_NOCARRIER
> in my opinion. What do you think?

I meant this view from a "listener" perspective; example from an
SNMP NMS perspective or even a dynamic route daemon, this is the only
really interesting state transition. So IMO, it only makes sense to send
netlink messages for these.

cheers,
jamal
