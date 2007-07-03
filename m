From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Mon, 02 Jul 2007 17:10:48 -0700
Message-ID: <46899408.4030407@hp.com>
References: <08FE5CC30C9A3F41BF819A502CF7BF6E019416BA@fmsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	"Kok,  Auke-jan H" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Jason Lunz <lunz@reflexsecurity.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <08FE5CC30C9A3F41BF819A502CF7BF6E019416BA@fmsmsx411.amr.corp.intel.com>
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

> There seems to be a lot of concern over obsoleting the e1000 driver
> too quickly, and with confusing users (and startup scripts) about which
> driver to load.

Yes.

> Obviously, we at Intel want to get e1000new into the kernel as quickly
> as possible, and to obsolete e1000 also as quickly as possible.  The
> point of this exercise is to reduce our support and maintenance burden,
> and e1000new has shown itself internally to be much easier to work on.
> 
> So how about this:
> - We include e1000new in 2.6.23, along side e1000.  We expose ICH9
>   device IDs in e1000new, and gate the rest of the IDs inside
>   #ifndef CONFIG_E1000.  This gives distis ICH9 support, along
>   with a guarantee of the known e1000 driver.  It also lets the more
>   bleeding-edge people turn off e1000 and run with just e1000new to
>   work out any kinks.
> - For 2.6.24, we reverse the situation:  Gate all device IDs in e1000
>   behind #ifndef CONFIG_E1000NEW, and expose all of them in e1000new.
>   At this point we (i.e. the community, not just Intel) should be 
>   confident in e1000new, and we can mark e1000 as obsolete.  It's still
>   a fallback option for those with old/funky/misconfigured hardware.
> - After a year (or whatever), we remove e1000.
> 
> Seems to me that this plan should appease either everybody or nobody.
> We get ICH9 support out there, e1000new gets in the kernel and
> exercised, and we get to set a definite date for obsoleting e1000.

What sort of timeframes are we looking at with 2.6.23 and then 2.6.24 
and how might they map to distro releases?  Much as everyone 
wants/encourages folks to test the kernel.org kernels and such, the 
_real_ exposure still seems to come with a distro release.

Rambling a bit, and recognizing that "e1000new" was probably just a 
strawman name, but I suspect that a _very_ different name for the new 
driver would be a good thing, rather than a varition on the e1000 theme. 
  "The Law of the Telephone Game" pretty much guaratees that something 
with "e1000" in its name will be shortened to just "e1000."

How about "elk" (ee el kay) - applying that same "telephone" game 
(consistency? nah) to e1000 to get e1k, which if you look at it quickly 
enough looks like elk.  OK, that's half in jest, but only half.  I may 
be wrong, but I don't think I've seen anyone shortening the current 
e1000 to e1k?

rick jones

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
