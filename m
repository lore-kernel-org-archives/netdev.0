From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next] be2net: log link status
Date: Thu, 23 Apr 2015 08:30:18 +0000
Message-ID: <385c1581-b18d-4476-b1c9-2120ff4e0095@CMEXHTCAS2.ad.emulex.com>
References: <1429707370-2792-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	"Ajit Kumar Khaparde" <Ajit.Khaparde@Emulex.Com>
To: Ivan Vecera <ivecera@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:53396 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756002AbbDWIap convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 04:30:45 -0400
In-Reply-To: <1429707370-2792-1-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Ivan Vecera [mailto:ivecera@redhat.com]
> 
> The driver unlike other drivers does not log link state changes.
> 
> Cc: Sathya Perla <sathya.perla@emulex.com>
> Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index fb0bc3c..e349131 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -662,6 +662,8 @@ void be_link_status_update(struct be_adapter *adapter, u8 link_status)
>  		netif_carrier_on(netdev);
>  	else
>  		netif_carrier_off(netdev);
> +
> +	netdev_info(netdev, "Link is %s\n", link_status ? "Up" : "Down");
>  }
> 
Acked-by: Sathya Perla <sathya.perla@emulex.com>
