From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH] xen/pvhvm: If xen_platform_pci=0 is set don't blow up.
Date: Wed, 4 Dec 2013 13:00:08 +0000
Message-ID: <529F2758.9070304@citrix.com>
References: <1386105246-14337-1-git-send-email-konrad.wilk@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <stefano.stabellini@eu.citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>,
	<boris.ostrovsky@oracle.com>, <leosilva@linux.vnet.ibm.com>,
	<ashley@ashleylai.com>, <peterhuewe@gmx.de>, <mail@srajiv.net>,
	<tpmdd@selhorst.net>, <tpmdd@sirrix.com>,
	<dmitry.torokhov@gmail.com>, <bhelgaas@google.com>,
	<plagnioj@jcrosoft.com>, <tomi.valkeinen@ti.com>,
	<tpmdd-devel@lists.sourceforge.net>, <linux-input@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-pci@vger.kernel.org>,
	<linux-fbdev@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1386105246-14337-1-git-send-email-konrad.wilk@oracle.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/12/13 21:14, Konrad Rzeszutek Wilk wrote:
> 
> Ian Campbell suggested getting rid of 'xen_platform_pci_unplug'
> but unfortunatly the xen-blkfront driver is using it, so we
> cannot do it.

I had a look at what blkfront was using this for and it seems dumb.  How
did we end up with the frontend driver working around toolstack bugs?
If HVM Linux guest didn't want (e.g.,) PV CDROM, the toolstack shouldn't
have created one.

And perhaps more importantly, if you actually want a PV CDROM in a HVM
guest, it's not possible.

David
