From: Andi Kleen <ak@suse.de>
Subject: Re: NIC renaming does not rename /proc/sys/net/ipv4 Was: Re: NICs
	trading places ?
Date: 29 Mar 2003 13:29:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1048940960.2176.86.camel@averell>
References: <20030328221037.GB25846@suse.de.suse.lists.linux.kernel>
	<p73isu2zsmi.fsf@oldwotan.suse.de>  <20030329121755.GA17169@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Dave Jones <davej@codemonkey.org.uk>,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20030329121755.GA17169@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2003-03-29 at 13:17, bert hubert wrote:
> On Sat, Mar 29, 2003 at 05:47:17AM +0100, Andi Kleen wrote:
> > Dave Jones <davej@codemonkey.org.uk> writes:
> > 
> > > I just upgraded a box with 2 NICs in it to 2.5.66, and found
> > > that what was eth0 in 2.4 is now eth1, and vice versa.
> > > Is this phenomenon intentional ? documented ?
> > 
> > Just assign mac addresses to names and run nameif early in boot.
> 
> A slight problem with that is that not all parts of /proc/sys get renamed
> this way:

Just rename at early boot before IP is set up.  That is what i usually
do - set up /etc/mactab and run it very early at boot.

Running it later is usually flakey. e.g. it can also give confusing
effects with old style named ip aliases.

-Andi
