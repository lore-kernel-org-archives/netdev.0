From: Roger Luethi <rl@hellgate.ch>
Subject: Re: pci-skeleton duplex check
Date: Thu, 12 Dec 2002 14:20:33 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021212132033.GA3224@k3.hellgate.ch>
References: <20021211132436.GA12529@k3.hellgate.ch> <Pine.LNX.4.44.0212112108070.10674-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0212112108070.10674-100000@beohost.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Dec 2002 21:42:44 -0500, Donald Becker wrote:
> Note that the second check ignores 100baseT4, despite it have priority
> over 10baseT-*.  That was intentional to work around, "a specific issue"
> with a transceiver.

That "specific issue" might be worth documenting. Information on such
quirks is hardest to come by.

> The is no extra cost to the extra bit, and it makes it clear we are
> testing for 10baseT-FDX.
> (The test was originally implemented as part of a complete set of
> cases.  The test code needed while building a driver is more complex
> than what you see in the concise final result.)

That was exactly the kind of answer I've been looking for. Nothing beats
some historic background. Thank you.

Roger
