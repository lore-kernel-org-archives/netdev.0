From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Mon, 14 Feb 2005 15:27:10 +0100
Message-ID: <20050214142710.GI31837@postel.suug.ch>
References: <1106232168.1041.125.camel@jzny.localdomain> <20050120153559.GG26856@postel.suug.ch> <1106576005.1652.1292.camel@jzny.localdomain> <20050124150634.GT23931@postel.suug.ch> <1106747313.1107.7.camel@jzny.localdomain> <1108134446.5523.22.camel@ganymede> <1108215923.1126.132.camel@jzny.localdomain> <1108246033.7554.18.camel@ganymede> <20050212223204.GG31837@postel.suug.ch> <1108340618.14978.66.camel@ganymede>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
To: Dan Siemon <dan@coverfire.com>
Content-Disposition: inline
In-Reply-To: <1108340618.14978.66.camel@ganymede>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> >  - The whole interface must take care of the byte order issues. This is
> >    the most tricky part.
> 
> I don't see how byte order issues are a problem when using SOAP.
> Example?

It depends on wehther your outline every qdisc/filter in the protocol.
If you do so it's not a problem but you have to extend your protocol
every time a new qdisc is introduced or an existing one changes. A
generic partly binary based protocol will have byte order issues.

My current idea, given I can't find an existing protocol, is to let
every netlink user describe its own format with a generic grammar so
the protocol can stay stable. One of the candidates is the netconf
specification which basically does what we need but is still in early
development.

> I'm curious exactly what your needs are.

Basically I need to be able to change the beavhiour of the message
parser to for example overwrite the sequence number checking in order
to do message multiplexing. It's not like I would be represenative
though.

> It does appear you are aiming for a somewhat more low level library than
> I am.  Whether or not that precludes some kind of merger I don't know.

Yes, it seems so. It's a pitty that we waste effort by doing the same
nearly work but I really need the low level API and the possibility to
customize the parsing and sending code.
