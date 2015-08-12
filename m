From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next 1/2] hv_netvsc: Set vRSS with num_chn in RNDIS
 filter
Date: Wed, 12 Aug 2015 19:05:28 +0000
Message-ID: <BN1PR0301MB0770719A2BC6A917F05C84C2CA7E0@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1439338472-21361-1-git-send-email-andschwa@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Schwartzmeyer <andschwa@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439338472-21361-1-git-send-email-andschwa@microsoft.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Andy Schwartzmeyer
> Sent: Tuesday, August 11, 2015 8:15 PM
> To: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: KY Srinivasan <kys@microsoft.com>; Andy Schwartzmeyer
> <andschwa@microsoft.com>; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: [PATCH net-next 1/2] hv_netvsc: Set vRSS with num_chn in RNDIS
> filter
> 
> Uses device_info->num_chn to pass user provided number of vRSS
> queues (from ethtool --set-channels) to rndis_filter_device_add. If
> nonzero and less than the maximum, set net_device->num_chn to the given
> value; else default to prior algorithm.
> 
> Always initialize struct device_info to 0, otherwise not all its fields
> are guaranteed to be 0, which is necessary when checking if num_chn has
> been purposefully set.
> 
> Signed-off-by: Andrew Schwartzmeyer <andschwa@microsoft.com>

Thank you!

Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
