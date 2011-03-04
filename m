From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH V4] Export ACPI _DSM provided firmware instance number
 and string name to sysfs
Date: Fri, 4 Mar 2011 10:43:14 -0800
Message-ID: <20110304104314.26265021@jbarnes-desktop>
References: <20110223125741.GA16473@fedora14-r610.blr.amer.dell.com>
	<20110302172508.GA2794@fedora14-r610.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-pci@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<netdev@vger.kernel.org>, <mjg@redhat.com>, <Matt_Domsch@Dell.com>,
	<Charles_Rose@Dell.com>, <Jordan_Hargrave@Dell.com>,
	<Shyam_Iyer@Dell.com>, <sfr@canb.auug.org.au>
To: <Narendra_K@Dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20110302172508.GA2794@fedora14-r610.oslab.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2 Mar 2011 22:34:17 +0530
<Narendra_K@Dell.com> wrote:

> On Wed, Feb 23, 2011 at 06:06:42PM +0530, K, Narendra wrote:
> > Hello,
> > 
> > This patch exports ACPI _DSM provided firmware instance number and
> > string name to sysfs.
> > 
> > V1 -> V2:
> > The attribute 'index' is changed to 'acpi_index' as the semantics of
> > SMBIOS provided device type instance and ACPI _DSM provided firmware
> > instance number are different.
> > 
> > V2 -> V3:
> > Matthew Garrett pointed out that 'sysfs_create_groups' does return an
> > error when there are no ACPI _DSM attributes available and because of
> > that the fallback to SMBIOS will not happen. As a result SMBIOS provided
> > attributes are not created. This version of the patch addresses the issue.
> > 
> 
> V3 -> V4:
> Select NLS if (DMI || ACPI) in drivers/pci/Kconfig to prevent build
> breakage from an 'allmodconfig'

Applied, fingers crossed this time. :)

-- 
Jesse Barnes, Intel Open Source Technology Center
