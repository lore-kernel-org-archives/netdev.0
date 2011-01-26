From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 00/20] Proposal for remaining BKL users
Date: Wed, 26 Jan 2011 12:31:30 +0100
Message-ID: <201101261231.30390.arnd@arndb.de>
References: <1295993854-4971-1-git-send-email-arnd@arndb.de>
	<20110126022223.GB28072@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mauro Carvalho Chehab <mchehab@redhat.com>,
	Frederic Weisbecker <fweisbec@gmail.com>, dri-devel@lists.freedesktop.org,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	"H. Peter Anvin" <hpa@zytor.com>, Ian Kent <raven@themaw.net>,
	linux-cifs@vger.kernel.org, Nick Bowler <nbowler@elliptictech.com>,
	linux-x25@vger.kernel.org,
	Takahiro Hirofuchi <hirofuchi@users.sourceforge.net>,
	Ross Cohen <rcohen@snurgle.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Stuart Swales <stuart.swales.croftnuisk@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	autofs@linux.kernel.org, Jeff Layton <jlayton@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Palash Bandyopadhyay <palash.bandyopadhyay@conexant.com>,
	linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.or
To: Greg KH <gregkh@suse.de>
Return-path: <dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org>
In-Reply-To: <20110126022223.GB28072@suse.de>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Sender: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
Errors-To: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
List-Id: netdev.vger.kernel.org

On Wednesday 26 January 2011, Greg KH wrote:
> On Tue, Jan 25, 2011 at 11:17:14PM +0100, Arnd Bergmann wrote:
> > I've gone through all the code in the kernel that
> > uses the big kernel lock and come up with a solution
> > that seems at least half-reasonable for each of them.
> > 
> > The decisions are somewhat arbitrary, but here is
> > what I'd suggest we do:
> > 
> > * Remove in 2.6.39:
> >    i830, autofs3, smbfs
> 
> I thought some people really wanted to keep i830.  Or was that i810?
>  I'll drop autofs3 and smbfs, thanks.

i810 needs to be kept, i830 is obsolete, see the patch changelogs
there. I assume that Dave Airlie will take both patches (i810 BKL
removal and i830 removal) into his 2.6.39 queue.

> > * Work around in an ugly way, but keep alive:
> >    * ufs, ipx, i810, cx25721
> > 
> > * Fix properly:
> >    * usbip, go7007, adfs, x25
> 
> Thanks for the usbip and go7007 patches, I'll queue them up.

It would be good if you could also take the cx25721 patch. It's
not the nicest one I've done, but it's a bug fix nonetheless.

Thanks,

	Arnd
