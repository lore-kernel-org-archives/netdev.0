From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next 2/2] hv_netvsc: Implement set_channels ethtool op
Date: Wed, 12 Aug 2015 19:05:48 +0000
Message-ID: <BN1PR0301MB0770620E321D7B4A3B1A0B70CA7E0@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1439338472-21361-1-git-send-email-andschwa@microsoft.com>
 <1439338472-21361-2-git-send-email-andschwa@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Schwartzmeyer <andschwa@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439338472-21361-2-git-send-email-andschwa@microsoft.com>
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
> Subject: [PATCH net-next 2/2] hv_netvsc: Implement set_channels ethtool
> op
> 
> This enables the use of ethtool --set-channels devname combined N to
> change the number of vRSS queues. Separate rx, tx, and other parameters
> are not supported. The maximum is rsscap.num_recv_que. It passes the
> given value to rndis_filter_device_add through the device_info->num_chn
> field.
> 
> If the procedure fails, it attempts to recover to the prior state. If
> the recovery fails, it logs an error and aborts.
> 
> Current num_chn is saved and restored when changing the MTU.
> 
> Signed-off-by: Andrew Schwartzmeyer <andschwa@microsoft.com>

Thank you!

Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
