From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC 00/20] Proposal for remaining BKL users
Date: Wed, 26 Jan 2011 10:22:23 +0800
Message-ID: <20110126022223.GB28072@suse.de>
References: <1295993854-4971-1-git-send-email-arnd@arndb.de>
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
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <1295993854-4971-1-git-send-email-arnd@arndb.de>
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

On Tue, Jan 25, 2011 at 11:17:14PM +0100, Arnd Bergmann wrote:
> I've gone through all the code in the kernel that
> uses the big kernel lock and come up with a solution
> that seems at least half-reasonable for each of them.
> 
> The decisions are somewhat arbitrary, but here is
> what I'd suggest we do:
> 
> * Remove in 2.6.39:
>    i830, autofs3, smbfs

I thought some people really wanted to keep i830.  Or was that i810?

 I'll drop autofs3 and smbfs, thanks.

> * Move to staging now, kill in 2.6.41 (or later):
>    appletalk, hpfs

Sounds good to me.

> * Work around in an ugly way, but keep alive:
>    * ufs, ipx, i810, cx25721
> 
> * Fix properly:
>    * usbip, go7007, adfs, x25

Thanks for the usbip and go7007 patches, I'll queue them up.

greg k-h
