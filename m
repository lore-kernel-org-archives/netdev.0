From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Mon, 19 May 2003 18:10:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520011053.GB10419@netnation.com>
References: <87d6iit4g7.fsf@deneb.enyo.de> <20030517.150933.74723581.davem@redhat.com> <87iss87gqd.fsf@deneb.enyo.de> <20030518.023151.77034834.davem@redhat.com> <20030519132819.S38814@shell.cyberus.ca> <Pine.LNX.4.51.0305191408490.1795@ns.istop.com> <20030519154852.I39024@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi <hadi@shell.cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20030519154852.I39024@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 19, 2003 at 06:37:43PM -0400, Jamal Hadi wrote:

> cache bucket distribution. This was a major problem before.

Was the hash distribution broken before even in the truly random case?
If so, the patch would likely help.  If not, it shouldn't really affect
the DoS case or the normal traffic case, because I doubt we have been the
target of any hashing-specific attacks.

I've been looking through the patch and there seem to be quite a few
changes, including some that may optimize it.  I'm about to test it out
on a test machine and do some benchmarks.  I'll post my results in the
next day or so.

Thanks,

Simon-
