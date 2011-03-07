From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH V4] Export ACPI _DSM provided firmware instance number and
 string name to sysfs
Date: Mon, 7 Mar 2011 21:04:05 +0300
Message-ID: <AANLkTimz662+L6eYJm2gh0NwWOxxzQV3503bcs-GMFGu@mail.gmail.com>
References: <20110223125741.GA16473@fedora14-r610.blr.amer.dell.com>
	<20110302172508.GA2794@fedora14-r610.oslab.blr.amer.dell.com>
	<20110304104314.26265021@jbarnes-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Narendra_K@dell.com, linux-pci@vger.kernel.org,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	mjg@redhat.com, Matt_Domsch@dell.com, Charles_Rose@dell.com,
	Jordan_Hargrave@dell.com, Shyam_Iyer@dell.com, sfr@canb.auug.org.au
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20110304104314.26265021@jbarnes-desktop>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4 March 2011 21:43, Jesse Barnes <jbarnes@virtuousgeek.org> wrote:
> On Wed, 2 Mar 2011 22:34:17 +0530
> <Narendra_K@Dell.com> wrote:
>
>> On Wed, Feb 23, 2011 at 06:06:42PM +0530, K, Narendra wrote:
>> > Hello,
>> >
>> > This patch exports ACPI _DSM provided firmware instance number and
>> > string name to sysfs.
>> >
>> > V1 -> V2:
>> > The attribute 'index' is changed to 'acpi_index' as the semantics of
>> > SMBIOS provided device type instance and ACPI _DSM provided firmware
>> > instance number are different.
>> >
>> > V2 -> V3:
>> > Matthew Garrett pointed out that 'sysfs_create_groups' does return an
>> > error when there are no ACPI _DSM attributes available and because of
>> > that the fallback to SMBIOS will not happen. As a result SMBIOS provided
>> > attributes are not created. This version of the patch addresses the issue.
>> >
>>
>> V3 -> V4:
>> Select NLS if (DMI || ACPI) in drivers/pci/Kconfig to prevent build
>> breakage from an 'allmodconfig'
>
> Applied, fingers crossed this time. :)
>

Hi,

It cannot be compiled if CONFIG_ACPI is not set.

drivers/pci/pci-label.c: In function 'pci_create_firmware_label_files':
drivers/pci/pci-label.c:366:2: error: implicit declaration of function
'device_has_dsm'
