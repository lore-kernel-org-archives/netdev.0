From: "David S. Miller" <davem@redhat.com>
Subject: Re: [bonding] compatibilty issues
Date: Mon, 29 Sep 2003 22:54:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929225425.42d5f84a.davem@redhat.com>
References: <20030929232534.GB93323@calma.pair.com>
	<3F78C262.30109@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chad@tindel.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F78C262.30109@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Sep 2003 19:38:10 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Well, if that's David's sentiment, then I respectfully disagree with that.

I really really really did intend to move these deprecated as fast as
possible.  This is because these bonding ioctls use SIOCDEVPRIVATE
values.

I don't think it's much of a burdon to remove their existence from
the 2.6.x copy of the driver, and I really wish you guys would do
this because then people would fix their tools.

You can very simply compile a copy of the tool that works with the
non-SIOCDEVPRIVATE ioctls we added to the bonding driver a LONG time
ago and it'll work with 2.4.x as well.  It doesn't break because
you made it work with the non-ambiguous ioctl values.
