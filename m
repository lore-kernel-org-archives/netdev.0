From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPX]: Fix checksum computation.
Date: Fri, 31 Oct 2003 13:53:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031031135328.2a997f6a.davem@redhat.com>
References: <200310312006.h9VK62Hh005910@hera.kernel.org>
	<1067635446.11564.92.camel@localhost.localdomain>
	<20031031132331.35a9aaca.davem@redhat.com>
	<1067637004.11564.98.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joe Perches <joe@perches.com>
In-Reply-To: <1067637004.11564.98.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 31 Oct 2003 13:50:04 -0800
Joe Perches <joe@perches.com> wrote:

> Was an old NG Sniffer being used to verify this?
> Sniffer had a long term problem with IPX checksums.

No, Arnaldo would verify the checksum by running the
old code and the new code, they produced different
checksums on every sendmsg() call.

He then tested it further by making sure he could use
netatalk successfully between a 2.4.x Linux appletalk
box and a 2.6.x system with the checksum patch applied.
Without the patch the 2.4.x system would reject all packets
sent by the 2.6.x box.

Don't assume that we're a bunch of fucknuts and didn't
verify things to the best of our abilities ok?  Thanks.

> Has the gcc team been contacted?

Why would we contact them before we even know if it's
a gcc bug or not?  It could be a sign extension issue or
something else that our brains are not grokking at the
moment.  Contacting the gcc team would be utterly premature.

Here is something you could do for us instead of your current
blabbering.  Why don't you take a look at the assembler diff I posted
and try to figure out how the before code produces a different
checksum than the after code?
