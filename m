From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Fw: [Bugme-new] [Bug 3657] New: downed interfaces acting as
 aliases
Date: Fri, 29 Oct 2004 00:06:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029000651.6fd7360f.davem@davemloft.net>
References: <20041028234649.2d4ed3b8.akpm@osdl.org>
	<20041028234502.203b42c3.davem@davemloft.net>
	<4181ED02.1060501@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com, mbm@alt.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4181ED02.1060501@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 00:10:58 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Why would you want this behaviour?  If it's configured down, it would
> seem that the user is trying to tell the system not to use it :)

Because IP addresses are assosciated with the host, not
a specific interface or link.  That is the model that
we've implemented since day one.

According to the RFCs, this is one of several valid models.

People hate it that when there's a decision of whether to
reply to something or not, we do whatever we can to reply
to packets we receive if we can find a way to do so.  This
approache increases the likelyhood that two hosts can
communicate successfully.  I need not remind people about
how much people dislike our default ARP behavior :-) but
it is done that way for the same reason.
