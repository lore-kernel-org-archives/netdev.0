From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] Wireless extensions rethink
Date: Fri, 18 Jun 2004 15:11:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618151117.2f191d7f.akpm@osdl.org>
References: <20040616204248.GA23617@bougret.hpl.hp.com>
	<40D0BD5B.201@pobox.com>
	<20040616223316.GA29618@bougret.hpl.hp.com>
	<40D0D265.3070804@pobox.com>
	<20040617174717.GA30460@bougret.hpl.hp.com>
	<40D1E185.2010201@pobox.com>
	<20040617185605.GA32216@bougret.hpl.hp.com>
	<40D1EC54.8000904@pobox.com>
	<20040617193154.GE32216@bougret.hpl.hp.com>
	<40D1F687.6030307@pobox.com>
	<20040617204644.GB3341@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, jgarzik@pobox.com, gwingerde@home.nl,
        sfeldma@pobox.com, netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040617204644.GB3341@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Coming into this with my lateness exceeded only by my lack of context, I'd
say that I share Jean's concern over making incompatible changes to the
wireless user<->kernel interface at this time.  If we can retain _both_
interfaces in 2.6, remove the old one in 2.7 then maybe that'll be OK.

But I do wonder whether this API is the uppermost issue with the wireless
drivers.  There seem to be a lot of bug reports, and these drivers are
*really* complex, and there are lots of out-of-tree drivers.  Aren't these
the things which we should be devoting cycles to?
