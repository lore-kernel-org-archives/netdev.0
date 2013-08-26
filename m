From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH RESEND V3 net-next 2/3] net: huawei_cdc_ncm: Introduce
 the huawei_cdc_ncm driver
Date: Mon, 26 Aug 2013 13:45:13 -0700
Message-ID: <1377549913.1877.12.camel@joe-AO722>
References: <mrkiko.rs@gmail.com>
	 <1377244590-8558-1-git-send-email-mrkiko.rs@gmail.com>
	 <1377244590-8558-3-git-send-email-mrkiko.rs@gmail.com>
	 <20130826.163125.1134768821551948034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: mrkiko.rs@gmail.com, gregkh@linuxfoundation.org, oliver@neukum.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130826.163125.1134768821551948034.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-08-26 at 16:31 -0400, David Miller wrote:
> From: Enrico Mioso <mrkiko.rs@gmail.com>
[]
> > +     int ret = 0;
> > +     struct usbnet *usbnet_dev = usb_get_intfdata(intf);
> > +     struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
> > +     struct cdc_ncm_ctx *ctx = drvstate->ctx;
> > +     bool callsub = (intf == ctx->control && drvstate->subdriver && drvstate->subdriver->resume); /* should we call subdriver's resume? ? */
> 
> Likewise, and order local function variable declarations by line
> length, longest to shortest.

I think the premise of local variable
declaration by line length is flawed.

It can't work when local variables are
dependent on initialization order as
above.

int ret; could be moved down below callsub
if really desired though.
