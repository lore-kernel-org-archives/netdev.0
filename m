From: Alan Jenkins <sourcejedi.lkml@googlemail.com>
Subject: Re: [PATCH 2/7 v3] initdev:kernel:USB init device discovery
	notification
Date: Fri, 7 Aug 2009 16:32:52 +0100
Message-ID: <9b2b86520908070832p2d1658b0t8b1d89d1a034bb9a@mail.gmail.com>
References: <20090804221506.GA9256@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: David VomLehn <dvomlehn@cisco.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752842AbZHGPc4@vger.kernel.org>
In-Reply-To: <20090804221506.GA9256@cuplxvomd02.corp.sa.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/4/09, David VomLehn <dvomlehn@cisco.com> wrote:
> From: Alan Stern <stern@rowland.harvard.edu>
>
> Use init device discovery infrastructure to provide notification of
> availability of USB devices.
>
> Signed-off-by: Alan Stern <stern@rowland.harvard.edu>
> Signed-off-by: David VomLehn <dvomlehn@cisco.com>
> ---
>  drivers/usb/core/hub.c |   26 ++++++++++++++++++++++++++
>  1 files changed, 26 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/usb/core/hub.c b/drivers/usb/core/hub.c
> index be86ae3..08baee0 100644
> --- a/drivers/usb/core/hub.c
> +++ b/drivers/usb/core/hub.c
> @@ -37,6 +37,20 @@
>  #endif
>  #endif
>
> +/* The mask of possible USB boot devices depends on what drivers and
> + * options have been configured into the kernel.  There are too many
> + * USB network config options to list here, so just assume it is always
> + * possible to have a USB network device.
> + */

That could be fixed though.  Make the "USB Network Adaptors" menu into
an option.  Then you just have e.g. "CONFIG_NETDEV_USB", plus the two
class devices outside the menu (CONFIG_USB_ACM and CONFIG_USB_WDM).

Alan
