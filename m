From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen/pvhvm: If xen_platform_pci=0 is set don't blow up.
Date: Wed, 4 Dec 2013 13:06:36 +0000
Message-ID: <1386162396.17466.77.camel@kazak.uk.xensource.com>
References: <1386105246-14337-1-git-send-email-konrad.wilk@oracle.com>
	 <529F2758.9070304@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	<stefano.stabellini@eu.citrix.com>,
	<xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>,
	<boris.ostrovsky@oracle.com>, <leosilva@linux.vnet.ibm.com>,
	<ashley@ashleylai.com>, <peterhuewe@gmx.de>, <mail@srajiv.net>,
	<tpmdd@selhorst.net>, <tpmdd@sirrix.com>,
	<dmitry.torokhov@gmail.com>, <bhelgaas@google.com>,
	<plagnioj@jcrosoft.com>, <tomi.valkeinen@ti.com>,
	<tpmdd-devel@lists.sourceforge.net>, <linux-input@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-pci@vger.kernel.org>,
	<linux-fbdev@vger.kernel.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <529F2758.9070304@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-12-04 at 13:00 +0000, David Vrabel wrote:
> On 03/12/13 21:14, Konrad Rzeszutek Wilk wrote:
> > 
> > Ian Campbell suggested getting rid of 'xen_platform_pci_unplug'
> > but unfortunatly the xen-blkfront driver is using it, so we
> > cannot do it.
> 
> I had a look at what blkfront was using this for and it seems dumb.  How
> did we end up with the frontend driver working around toolstack bugs?
> If HVM Linux guest didn't want (e.g.,) PV CDROM, the toolstack shouldn't
> have created one.

Note that this cdrom stuff is actually nothing to do with the unplug
variable -- it just happens to be right next to that check.

Not that the use of the unplug var there doesn't also look pretty odd...
