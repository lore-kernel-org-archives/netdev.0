From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH v3] if xen_platform_pci=0 is set don't blow up.
Date: Mon, 16 Dec 2013 18:00:25 -0700
Message-ID: <CAErSpo7F+-TZ_dGwsFtr7pra45hVqTv4HLuQNr-SR4MeLespYw@mail.gmail.com>
References: <1387206250-13963-1-git-send-email-konrad.wilk@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jens Axboe <axboe@kernel.dk>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	ian.campbell@citrix.com, xen-devel@lists.xenproject.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	boris.ostrovsky@oracle.com, David Vrabel <david.vrabel@citrix.com>,
	leosilva@linux.vnet.ibm.com, ashley@ashleylai.com,
	=?UTF-8?Q?Peter_H=C3=BCwe?= <peterhuewe@gmx.de>, mail@srajiv.net,
	tpmdd@selhorst.net, Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	plagnioj@jcrosoft.com, tomi.valkeinen@ti.com,
	tpmdd-devel@lists.sourceforge.net,
	"linux-input@vger.kernel.org" <linux-input@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	linux-fbdev@vger.kernel.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1387206250-13963-1-git-send-email-konrad.wilk@oracle.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 16, 2013 at 8:04 AM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> The first patch:
>  [PATCH v3 1/2] xen/pvhvm: If xen_platform_pci=0 is set don't blow up
>
> I would like to commit to stable as it is fixing an eggregious bug -
> where we blow up if the guest config has: "xen_platform_pci=0" setup.
> This bug has been in existence for years and it is time to stamp it out.
>
> The second patch is a cleanup - not a stable candidate.
>
> It touches all of the Xen frontend drivers and adds the logic of:
> "if user disabled us, don't init" - with variations. As you can
> specify exactly which ones you want to init and which ones
> not (Linux runtime parameter 'xen_emul_unplug'). But for the majority
> of drivers - it is just an on/off switch.
>
> Since it touches a lot of maintainers I figured I would send it
> to Linus on Wednesday or Thursday.
>
> Thank you!
>
>  arch/x86/xen/platform-pci-unplug.c         | 79 ++++++++++++++++++++++++++++--
>  drivers/block/xen-blkfront.c               |  4 +-
>  drivers/char/tpm/xen-tpmfront.c            |  4 ++
>  drivers/input/misc/xen-kbdfront.c          |  4 ++
>  drivers/net/xen-netfront.c                 |  2 +-
>  drivers/pci/xen-pcifront.c                 |  4 ++
>  drivers/video/xen-fbfront.c                |  4 ++
>  drivers/xen/xenbus/xenbus_probe_frontend.c |  2 +-
>  include/xen/platform_pci.h                 | 25 +++++++++-
>  9 files changed, 119 insertions(+), 9 deletions(-)

If you want it:

Acked-by: Bjorn Helgaas <bhelgaas@google.com>

for the PCI parts.

>
> Konrad Rzeszutek Wilk (2):
>       xen/pvhvm: If xen_platform_pci=0 is set don't blow up (v3).
>       xen/pvhvm: Remove the xen_platform_pci int.
>
