From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] ethtool semantics
Date: Mon, 7 Jun 2004 14:57:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607145723.41da5783.davem@redhat.com>
References: <20040607212804.GA17012@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20040607212804.GA17012@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Jun 2004 23:28:04 +0200
Roger Luethi <rl@hellgate.ch> wrote:

> What is the correct response if a user passes ethtool speed or duplex
> arguments while autoneg is on? Some possible answers are:
> 
> a) Yell at the user for doing something stupid.
> 
> b) Fail silently (i.e. ignore command).
> 
> c) Change advertised value accordingly and initiate new negotiation.
> 
> d) Consider "autoneg off" implied, force media accordingly.
> 
> The ethtool(8) man page I'm looking at doesn't address that question. The
> actual behavior I've seen is b) which is by far my least preferred
> solution.

speed and duplex fields should be silently ignored in this case
