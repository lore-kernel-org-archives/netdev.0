From: Greg KH <greg@kroah.com>
Subject: Re: [stable] 2.6.21 known regressions (v2) (for -stable team)
Date: Sat, 28 Apr 2007 11:19:33 -0700
Message-ID: <20070428181933.GA9811@kroah.com>
References: <463375E5.5040108@googlemail.com> <200704281252.20381.gene.heskett@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Jeff Mahoney <jeffm@suse.com>,
	Vincent Frentzel <zcecc22@ucl.ac.uk>,
	Riccardo Ricci <rricci@nuovanetmore.it>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Brownell <david-b@pacbell.net>,
	Giorgio Lando <patroclo7@gmail.com>,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	H??kan Lindqvist <lindqvist@netstar.se>,
	Fran??ois Valenduc <francois.valenduc@skynet.be>,
	"Udo A. Steinberg" <us15@os.inf.tu-dresden.de>,
	linux-acpi@vger.kernel.org, Thomas Meyer <thomas.mey@web.de>,
	stable@kernel.org, Len Brown <len.brown@intel.com>,
	Dave Jones <davej@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Francois SIMOND <curio@free.fr>,
	Andrew Morton <akpm@linux-foundation.org>,
	reiserfs-dev@namesy
To: Gene Heskett <gene.heskett@gmail.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200704281252.20381.gene.heskett@gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 28, 2007 at 12:52:19PM -0400, Gene Heskett wrote:
> On Saturday 28 April 2007, Michal Piotrowski wrote:
> >Hi all,
> >
> >Here is a list of known regressions reported after 2.6.21 release.
> >
> >Feel free to add new regressions/remove fixed etc.
> >http://kernelnewbies.org/known_regressions
> >
> I went here, but without a login the page is immutable
> 
> Therefore I'll add it here
> 
> Subject		:proprietary belkin upsd turns into cpu hog
> Submitter	:gene.heskett@gmail.com
> Reference	:something changed in how /dev/ttyUSB's handle 1 and 2 byte messages 
> from pl2303 usb<->serial adaptors.

Last time this came up, I asked you to enable debugging in the driver to
see the data flow through it and find out if it really is the driver at
fault here.

Did you do this?  Did anything happen that was "odd"?

Can you do a 'git bisect' of Linus's tree to try to track down the
issue?

> Also, assignation of ttyUSB#'s is volatile depending on phase of the
> moon when booted.

That's always been the case, ever since the 2.2 kernel releases.  Please
use udev if you want persistent device names for your tty USB devices.

thanks,

greg k-h
