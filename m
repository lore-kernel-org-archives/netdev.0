From: Thomas Graf <tgraf@suug.ch>
Subject: Re: ACPI/HT or Packet Scheduler BUG?
Date: Sat, 16 Apr 2005 20:21:14 +0200
Message-ID: <20050416182114.GL4114@postel.suug.ch>
References: <Pine.LNX.4.61.0504141840420.13546@blackblue.iasi.rdsnet.ro> <1113601029.4294.80.camel@localhost.localdomain> <1113601446.17859.36.camel@localhost.localdomain> <1113602052.4294.89.camel@localhost.localdomain> <20050415225422.GF4114@postel.suug.ch> <20050416014906.GA3291@gondor.apana.org.au> <20050416110639.GI4114@postel.suug.ch> <20050416112329.GA31847@gondor.apana.org.au> <20050416113446.GJ4114@postel.suug.ch> <1113667447.7419.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steven Rostedt <rostedt@goodmis.org>,
	netdev <netdev@oss.sgi.com>,
	Tarhon-Onu Victor <mituc@iasi.rdsnet.ro>, kuznet@ms2.inr.ac.ru,
	devik@cdi.cz, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262715AbVDPSU7@vger.kernel.org>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1113667447.7419.9.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <1113667447.7419.9.camel@localhost.localdomain> 2005-04-16 12:04
> The rule of "optimize for the common" fails miserably in this case
> because this is not a common case/usage of qdiscs.

I tend to agree. OTOH, I use exactly such setups... ;->

> I have a feeling though that the patch went in due to
> dude-optimizing-loopback as pointed by Herbert. 

I checked, it was in fact during the lockless loopback
optimizations.

> Maybe worth reverting to the earlier scheme if it is going to continue
> to be problematic.

Let me first check and see how the locking can be done at best, it
doesn't match the principles in sch_generic.c anyway at the moment
so once we know how to do the locking efficient and how to remove the
error proneess we can see if the optimization fits in without problems
and make a call.
