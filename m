From: <Narendra_K@Dell.com>
Subject: Re: [PATCH V3] Export ACPI _DSM provided firmware instance number
 and string name to sysfs
Date: Mon, 21 Mar 2011 08:30:20 -0700
Message-ID: <20110321154817.GA25662@fedora14-r610.oslab.blr.amer.dell.com>
References: <20110223125741.GA16473@fedora14-r610.blr.amer.dell.com>
 <20110223124419.GA5695@srcf.ucam.org>
 <20110223132147.GB16707@fedora14-r610.blr.amer.dell.com>
 <AANLkTiki5XdEe1QjP6_GfkFGD39odyVES_yC4QcQc33z@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <mjg59@srcf.ucam.org>, <linux-pci@vger.kernel.org>,
	<linux-hotplug@vger.kernel.org>, <netdev@vger.kernel.org>,
	<Matt_Domsch@Dell.com>, <Charles_Rose@Dell.com>,
	<Jordan_Hargrave@Dell.com>, <Shyam_Iyer@Dell.com>
To: <a.beregalov@gmail.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <AANLkTiki5XdEe1QjP6_GfkFGD39odyVES_yC4QcQc33z@mail.gmail.com>
Content-Language: en-US
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 20, 2011 at 03:45:33PM +0530, Alexander Beregalov wrote:
> On 23 February 2011 16:00,  <Narendra_K@dell.com> wrote:
> > On Wed, Feb 23, 2011 at 06:14:19PM +0530, Matthew Garrett wrote:
> >> I think this version will still break the build. You need to depend on
> >> CONFIG_NLS.
> >
> > Matthew,
> >
> > Thanks. I posted a patch to linux-next to fix the build failure.
> 
> Hi,
> it still does not work
> 
> drivers/pci/Kconfig:
> select NLS if (DMI || ACPI)
> 
>  $ egrep "G_ACPI=|_DMI=|G_NLS=" .config
> CONFIG_DMI=y
> CONFIG_ACPI=y
> CONFIG_NLS=m
> 
> pci-label.c:(.text+0xb80a): undefined reference to `utf16s_to_utf8s'

Hi,

With '2.6.38' mainline kernel + 'patch-v2.6.38-next-20110321', i could
not see this issue. With CONFIG_DMI=y and CONFIG_ACPI=y, CONFIG_NLS is
set to 'y' even when doing an 'allmodconfig' because of the 

'select NLS if (DMI || ACPI)' in drivers/pci/Kconfig.

Please let me know if i am missing something so that i can
replicate this failure.

With regards,
Narendra K

