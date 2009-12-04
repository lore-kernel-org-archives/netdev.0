From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Fri, 4 Dec 2009 09:05:25 +0000
Message-ID: <20091204090524.GB6478@ff.dom.local>
References: <81bfc67a0911232217n41b9ac02w3b7770b789e5d209@mail.gmail.com>
	<20091124111946.GA7883@ff.dom.local>
	<81bfc67a0911250606k1ec76354n217da9ca20b3517c@mail.gmail.com>
	<20091125191105.GA3167@ami.dom.local>
	<81bfc67a0911271007o1fb8f8c2vdd36e8585280e4da@mail.gmail.com>
	<20091127213640.GA2611@ami.dom.local>
	<81bfc67a0911271435g4106652bpe8c9ea07893d0ebd@mail.gmail.com>
	<20091127224206.GA3350@ami.dom.local>
	<81bfc67a0912031749y15faed66s9c8a924684c97a19@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Frans Pop <elendil@planet.nl>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <81bfc67a0912031749y15faed66s9c8a924684c97a19@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, Dec 03, 2009 at 08:49:17PM -0500, Caleb Cushing wrote:
> >
> > modprobe -r e1000e
> > modprobe e1000e IntMode=0
> >
> > Jarek P.
> >
> tested on kernel behaving properly no change. what do these modes do?

e1000e by default uses MSI-X interrupts if possible, which are most
modern. If there are some problems IntMode lets us try older types,
so I rather meant it for the misbehaving kernel.

> 
> I've installed a 10/100 linksys nic into my system. it appears to be
> working fine on a bad kernel (2.6.32-final tested and for sure
> verified). I've only tested it once though. my laptop died so direct
> connection between that won't work. can I test between these 2 nics?
> (suppose no real reason why not) but what should I proceed with at
> this point?

If you have it fixed easily with another nic you should first
reconsider if this debugging is worth of your time. Of course it's
could be very useful for the kernel (unless it's a hardware fault),
but on the other hand this is a popular nic, tested by many people.

Then, if you find time for such testing, I'd suggest to try mainly
2.6.32 - I'm not sure if you tried it with e1000e. So if after longer
testing both linksys and e1000e you find only the latter has problems
I think you should open the new report in bugzilla for e1000e and
submit things like: dmesg, .config, lspci -v from 2.6.32, and if
possible the same things from the last kernel which didn't have these
problems. Add some references to previous attempts in bugzilla and
this thread. (Btw, any reproducible tests should be fine.)

Jarek P.

------------------------------------------------------------------------------
Join us December 9, 2009 for the Red Hat Virtual Experience,
a free event focused on virtualization and cloud computing. 
Attend in-depth sessions from your desk. Your couch. Anywhere.
http://p.sf.net/sfu/redhat-sfdev2dev
