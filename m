From: Dan Siemon <dan@coverfire.com>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Tue, 15 Feb 2005 15:28:14 -0500
Message-ID: <1108499294.5465.22.camel@ganymede>
References: <1106232168.1041.125.camel@jzny.localdomain>
	 <20050120153559.GG26856@postel.suug.ch>
	 <1106576005.1652.1292.camel@jzny.localdomain>
	 <20050124150634.GT23931@postel.suug.ch>
	 <1106747313.1107.7.camel@jzny.localdomain>
	 <1108134446.5523.22.camel@ganymede>
	 <1108215923.1126.132.camel@jzny.localdomain>
	 <1108246033.7554.18.camel@ganymede> <20050212223204.GG31837@postel.suug.ch>
	 <1108340618.14978.66.camel@ganymede>
	 <20050214142710.GI31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050214142710.GI31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-14-02 at 15:27 +0100, Thomas Graf wrote:
> > I'm curious exactly what your needs are.
> 
> Basically I need to be able to change the beavhiour of the message
> parser to for example overwrite the sequence number checking in order
> to do message multiplexing. It's not like I would be represenative
> though.
> 
> > It does appear you are aiming for a somewhat more low level library than
> > I am.  Whether or not that precludes some kind of merger I don't know.
> 
> Yes, it seems so. It's a pitty that we waste effort by doing the same
> nearly work but I really need the low level API and the possibility to
> customize the parsing and sending code.

Perhaps we could agree on a single API for the low-level message parsing
and netlink message construction.  At least then we would not be
duplicating bug-fixes in our netlink code.

Whether or not this sharing would be useful probably depends on if you
would continue to maintain your own non-GObject APIs for the various
QDiscs and classifiers.  GObject makes the creation and maintenance of
the language bindings much easier so its basically necessary for my
goals.

I'm willing to switch the underlying implementation of LQL to use your
more featureful NL implementation if that means there won't be two
competing C APIs to the individual QDiscs etc.

-- 
OpenPGP key: http://www.coverfire.com/files/pubkey.txt
Key fingerprint: FB0A 2D8A A1E9 11B6 6CA3  0C53 742A 9EA8 891C BD98
