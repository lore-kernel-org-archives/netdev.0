From: "Andrew Grover" <andy.grover@gmail.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 16:57:46 -0700
Message-ID: <c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
References: <1183138159.17243.16.camel@blaa>
	<20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org>
	<46857C08.4030303@intel.com>
	<20070629150350.414553d4.akpm@linux-foundation.org>
	<4685838D.9080108@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4685838D.9080108@garzik.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 6/29/07, Jeff Garzik <jeff@garzik.org> wrote:
> Given past history with duplicate drivers and the problems that they
> cause -- I know, I've caused some of those problems :( -- I strongly
> recommend against when it can be avoided.
>
> Leaving e1000 with current hardware, and a new e1001 for newer hardware
> should be easier to manage for all involved, without the headaches that
> duplicate drivers cause.
>
> An "e1001" approach also means we have a much greater chance of
> encouraging Intel down the path of clean driver-ness.

When I was at Intel, I heard a lot of "the linux community won't let
us split the driver". "Oh well, guess we gotta keep lugging around all
the old crap." So it was a (perhaps misunderstood) desire to make you
guys happy that led to e1000 turning into a monster.

I think making e1000new ICH9-and-newer isn't really the best place to
split it. The Windows e1000 driver got split on the PCI->PCIe
transition, something that clearly delineated what nics one driver
supported, and the other. There's no real technical reason for
splitting now other than "this was when e1000old collapsed under its
own weight".

The PCIe adapters are also the first ones to support multiple queues
IIRC, maybe that would be an another actual technical reason to split
it there?

-- Andy

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
