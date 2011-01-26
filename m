From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 00/20] Proposal for remaining BKL users
Date: Wed, 26 Jan 2011 14:45:17 +0100
Message-ID: <201101261445.17751.arnd@arndb.de>
References: <1295993854-4971-1-git-send-email-arnd@arndb.de>
	<201101261231.30390.arnd@arndb.de> <4D400C5D.80004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Frederic Weisbecker <fweisbec@gmail.com>, dri-devel@lists.freedesktop.org,
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
	netdev@vger.kernel.org, Greg KH <gregkh@suse.de>,
	linux-kernel@vger.kernel.org,
	Palash Bandyopadhyay <palash.bandyopadhyay@conexant.com>,
	linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Andrew Hendry
To: Mauro Carvalho Chehab <mchehab@redhat.com>
Return-path: <dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org>
In-Reply-To: <4D400C5D.80004@redhat.com>
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

On Wednesday 26 January 2011, Mauro Carvalho Chehab wrote:
> I guess you're meaning cx25821, right? 

Right, sorry for the typo.
 
> Palash should take a look on it and review. This is a device that allows
> 12 simultaneous streams, so, I suspect that he'll need to do some
> changes at the locking schema, to avoid performance bottlenecks.

I would be surprised if there was any measurable performance change.
The BKL was used only in the open() function to iterate the device
list, and that code is nowhere on a critical path, as far as I can tell.

	Arnd
