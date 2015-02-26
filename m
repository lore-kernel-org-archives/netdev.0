From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] Implement Hyper-V netvsc_get_channels() ethool op
Date: Thu, 26 Feb 2015 21:01:45 +0000
Message-ID: <BN1PR0301MB07706C93E34C1EA5F52770B4CA140@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1424980840-33714-1-git-send-email-andrew@schwartzmeyer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"hall5714@vandals.uidaho.edu" <hall5714@vandals.uidaho.edu>,
	"keithd@vandals.uidaho.edu" <keithd@vandals.uidaho.edu>,
	"doma8101@vandals.uidaho.edu" <doma8101@vandals.uidaho.edu>
To: Andrew Schwartzmeyer <andrew@schwartzmeyer.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424980840-33714-1-git-send-email-andrew@schwartzmeyer.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andrew Schwartzmeyer [mailto:andrew@schwartzmeyer.com]
> Subject: [PATCH] Implement Hyper-V netvsc_get_channels() ethool op

Please add net-next to the subject (the patch should also be based on that tree).
Also the "hyperv: " word should come first.
Like this:
[PATCH net-next] hyperv: Implement netvsc_get_channels() ethool op

> --- a/drivers/net/hyperv/rndis_filter.c
> +++ b/drivers/net/hyperv/rndis_filter.c
> @@ -1094,6 +1094,7 @@ int rndis_filter_device_add(struct hv_device *dev,

On top part of this function, you also need to initialize max_chn = 1 around here:
        /* Initialize the rndis device */
        net_device = hv_get_drvdata(dev);
        net_device->num_chn = 1;

because the query for rsscap.num_recv_que is not done on all VSP versions.

Thanks,
- Haiyang
