From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] Export ACPI _DSM provided firmware instance number and
 string name to sysfs
Date: Mon, 10 Jan 2011 10:48:26 -0800
Message-ID: <E31FB011129F30488D5861F3839049151D10F8EF9D@BLRX7MCDC201.AMER.DELL.COM>
References: <20101222170737.GA2428@fedora14-r610.oslab.blr.amer.dell.com>
	<20101223143203.GA12256@auslistsprd01.us.dell.com>
	<20101223194927.GA2717@fedora14-r610.oslab.blr.amer.dell.com>
 <20110107142750.21ea39f0@jbarnes-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <Matt_Domsch@Dell.com>, <linux-pci@vger.kernel.org>,
	<linux-hotplug@vger.kernel.org>, <netdev@vger.kernel.org>,
	<Jordan_Hargrave@Dell.com>, <Charles_Rose@Dell.com>,
	<Vijay_Nijhawan@Dell.com>
To: <jbarnes@virtuousgeek.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20110107142750.21ea39f0@jbarnes-desktop>
Content-Language: en-US
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Jesse Barnes [mailto:jbarnes@virtuousgeek.org]
> Sent: Saturday, January 08, 2011 3:58 AM
> To: K, Narendra
> Cc: Domsch, Matt; linux-pci@vger.kernel.org; linux-
> hotplug@vger.kernel.org; netdev@vger.kernel.org; Hargrave, Jordan;
> Rose, Charles; Nijhawan, Vijay
> Subject: Re: [PATCH] Export ACPI _DSM provided firmware instance number
> and string name to sysfs
> 
> On Thu, 23 Dec 2010 11:24:36 -0800
> <Narendra_K@Dell.com> wrote:
> 
> > On Thu, Dec 23, 2010 at 08:02:03PM +0530, Domsch, Matt wrote:
> > > On Wed, Dec 22, 2010 at 08:42:39AM -0800, Narendra_K@Dell.com
> wrote:
> > > > Hello,
> > > >
> > > > This patch exports ACPI _DSM provided firmware instance number
> and
> > > > string name to sysfs.
> > > >
> > > > Please review -
> > >
> > > There are now two different meanings for the 'index' file:
> > >
> > > 1) SMBIOS-provided "type instance" value, which I've only seen in
> > >    range [1..N] for N devices, monotonically stepwise increasing.
> > >
> > > 2) ACPI-provided "index" value, which per spec only needs to be a
> > >    "sort key", not starting at 0 or 1, and while monotonically
> > >    increasing, not necessarily stepwise.  It's perfectly valid for
> the
> > >    values to be (12, 16, 27, 29) if that's convenient for BIOS to
> > >    generate.
> > >
> > > Therefore, a consumer of this value (such as biosdevname) must know
> > > which of the two it's dealing with, and either accept the value as-
> is,
> > > or sort the value list.  While I suppose it could sort the value
> list
> > > in either case, I'd prefer the ACPI value to be exposed in its own
> > > file, perhaps 'acpi_index', to make this explicit rather than
> > > implicit.
> > >
> > > 'label' is fine for either case, with ACPI taking priority over
> > > SMBIOS if both happen to be present.
> > >
> 
> Applied, thanks.

Jesse,

Thank you.

With regards,
Narendra K



