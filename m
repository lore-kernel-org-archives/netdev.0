From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH V3] Export ACPI _DSM provided firmware instance number and
 string name to sysfs
Date: Sun, 20 Mar 2011 13:15:33 +0300
Message-ID: <AANLkTiki5XdEe1QjP6_GfkFGD39odyVES_yC4QcQc33z@mail.gmail.com>
References: <20110223125741.GA16473@fedora14-r610.blr.amer.dell.com>
	<20110223124419.GA5695@srcf.ucam.org>
	<20110223132147.GB16707@fedora14-r610.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mjg59@srcf.ucam.org, linux-pci@vger.kernel.org,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	Matt_Domsch@dell.com, Charles_Rose@dell.com,
	Jordan_Hargrave@dell.com, Shyam_Iyer@dell.com
To: Narendra_K@dell.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20110223132147.GB16707@fedora14-r610.blr.amer.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23 February 2011 16:00,  <Narendra_K@dell.com> wrote:
> On Wed, Feb 23, 2011 at 06:14:19PM +0530, Matthew Garrett wrote:
>> I think this version will still break the build. You need to depend on
>> CONFIG_NLS.
>
> Matthew,
>
> Thanks. I posted a patch to linux-next to fix the build failure.

Hi,
it still does not work

drivers/pci/Kconfig:
select NLS if (DMI || ACPI)

 $ egrep "G_ACPI=|_DMI=|G_NLS=" .config
CONFIG_DMI=y
CONFIG_ACPI=y
CONFIG_NLS=m

pci-label.c:(.text+0xb80a): undefined reference to `utf16s_to_utf8s'
