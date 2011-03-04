From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH V4] Export ACPI _DSM provided firmware instance number
 and string name to sysfs
Date: Fri, 4 Mar 2011 10:38:52 -0800
Message-ID: <20110304103852.1bff3753@jbarnes-desktop>
References: <20110223125741.GA16473@fedora14-r610.blr.amer.dell.com>
	<20110302172508.GA2794@fedora14-r610.oslab.blr.amer.dell.com>
	<20110304164957.GA2913@fedora14-r610.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-pci@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<netdev@vger.kernel.org>, <mjg@redhat.com>, <Matt_Domsch@Dell.com>,
	<Charles_Rose@Dell.com>, <Jordan_Hargrave@Dell.com>,
	<Shyam_Iyer@Dell.com>, <sfr@canb.auug.org.au>
To: <Narendra_K@Dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20110304164957.GA2913@fedora14-r610.oslab.blr.amer.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Mar 2011 08:28:59 -0800
<Narendra_K@Dell.com> wrote:

> On Wed, Mar 02, 2011 at 10:34:17PM +0530, K, Narendra wrote:
> > On Wed, Feb 23, 2011 at 06:06:42PM +0530, K, Narendra wrote:
> > > Hello,
> > >
> > > This patch exports ACPI _DSM provided firmware instance number and
> > > string name to sysfs.
> > >
> > > V1 -> V2:
> > > The attribute 'index' is changed to 'acpi_index' as the semantics of
> > > SMBIOS provided device type instance and ACPI _DSM provided firmware
> > > instance number are different.
> > >
> > > V2 -> V3:
> > > Matthew Garrett pointed out that 'sysfs_create_groups' does return an
> > > error when there are no ACPI _DSM attributes available and because of
> > > that the fallback to SMBIOS will not happen. As a result SMBIOS provided
> > > attributes are not created. This version of the patch addresses the issue.
> > >
> > 
> > V3 -> V4:
> > Select NLS if (DMI || ACPI) in drivers/pci/Kconfig to prevent build
> > breakage from an 'allmodconfig'
> > 
> > Matthew,
> > Thanks for the suggestion.
> > 
> > From: Narendra K <narendra_k@dell.com>
> > Subject: [PATCH] Export ACPI _DSM provided firmware instance number and string to sysfs
> >
> 
> Hi Jesse,
> 
> Does Version 4 of the patch look good for inclusion ? Please let us know
> if there are any concerns.

Oh sorry, I was looking in the wrong mailbox, I'll pull this one in now.

-- 
Jesse Barnes, Intel Open Source Technology Center
