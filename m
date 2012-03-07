From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] net/hyperv: Advertise hv_netvsc instead of netvsc as
 driver name
Date: Wed, 7 Mar 2012 19:57:53 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DCD4CA3@TK5EX14MBXC227.redmond.corp.microsoft.com>
References: <1331147131-6660-1-git-send-email-haiyangz@microsoft.com>
 <20120307192204.GA9163@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	Olaf Hering <olaf@aepfle.de>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120307192204.GA9163@kroah.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Greg KH [mailto:greg@kroah.com]
> Sent: Wednesday, March 07, 2012 2:22 PM
> To: Haiyang Zhang
> Cc: KY Srinivasan; davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; Olaf Hering
> Subject: Re: [PATCH] net/hyperv: Advertise hv_netvsc instead of netvsc as
> driver name
> 
> On Wed, Mar 07, 2012 at 11:05:31AM -0800, Haiyang Zhang wrote:
> > From: Olaf Hering <olaf@aepfle.de>
> >
> > Signed-off-by: Olaf Hering <olaf@aepfle.de>
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > ---
> >  drivers/net/hyperv/netvsc_drv.c |    6 ++++--
> >  1 files changed, 4 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/net/hyperv/netvsc_drv.c
> b/drivers/net/hyperv/netvsc_drv.c
> > index 0ae7a1a..53d1ee5 100644
> > --- a/drivers/net/hyperv/netvsc_drv.c
> > +++ b/drivers/net/hyperv/netvsc_drv.c
> > @@ -40,6 +40,8 @@
> >
> >  #include "hyperv_net.h"
> >
> > +#define MODULE_NAME "hv_netvsc"
> 
> No, please use the built-in macro for this and don't define your own,
> that's totally redundant.

I have submitted a patch using the built-in KBUILD_MODNAME.
Thanks,
- Haiyang
