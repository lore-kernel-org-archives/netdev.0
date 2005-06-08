From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: netdev munching messages again?
Date: Wed, 8 Jun 2005 18:28:09 +0100
Message-ID: <20050608172809.GF5520@linux-mips.org>
References: <20050607140842.778143000@axs> <20050607140901.632982000@axs> <20050607213621.GG20969@postel.suug.ch> <20050607.144237.93024273.davem@davemloft.net> <20050608132953.GK20969@postel.suug.ch> <1118238264.6382.43.camel@localhost.localdomain> <20050608160444.GA17777@linux-mips.org> <20050608161314.GM20969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050608161314.GM20969@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 08, 2005 at 06:13:14PM +0200, Thomas Graf wrote:

> * Ralf Baechle <20050608160444.GA17777@linux-mips.org> 2005-06-08 17:04
> > Turns out that Thomas Graf's Email was intercepted by the spam filter,
> > so I've tweaked the filter setup a bit - probably at the price of
> > sacrificing some of the filter's effectivity.
> 
> Can you tell me why it was filtered? It might be a problem with my
> patch script which I could fix on my side. How much work would it
> be to whitelist a few people?

Whitelists tend to be problematic due to the enormous amounts of spam
and malware emails that come with forged email addresses.

I'll send you the rules in question and the original spamyness scores they
did compute in separate email, it's somewhat bigish.

> The weird thing is that patches 6-7 which could not be delivered
> immediately due to connection refused from oss.sgi.com came through
> fine.

Whatever it was, it was probably a separate issue from this spamfilter
faux-pas.  Note there is a firewall in front of oss.sgi.com which will
accept the SMTP TCP connection only to drop the connection shortly after
if it can't build a connection to the "real" oss.  So if you only get a
connection refused message when telneting to oss it really means the
firewall had some issues.  Unfortunately I don't have any control over
it, if I had I'd replace it with a nice patchcable ;-)

  Ralf
