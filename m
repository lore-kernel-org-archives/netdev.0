From: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
Subject: RE: [PATCH] vxge: Remember to release firmware after upgrading
 firmware {nodisc}
Date: Thu, 13 Jan 2011 12:35:14 -0800
Message-ID: <FCA91A92EE52B041906A0358FC28FCC38EFB6B2F34@FRE1EXCH02.hq.exar.com>
References: <alpine.LNX.2.00.1101132119080.11347@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jon Mason <Jon.Mason@exar.com>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>
To: Jesper Juhl <jj@chaosbits.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.exar.com ([204.154.183.83]:54847 "EHLO smtp1.exar.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751663Ab1AMUfQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 15:35:16 -0500
In-Reply-To: <alpine.LNX.2.00.1101132119080.11347@swampdragon.chaosbits.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Regardless of whether the firmware update being performed by
> vxge_fw_upgrade() is a success or not we must still remember to always
> release_firmware() before returning.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  vxge-main.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
> index 1ac9b56..c81a651 100644
> --- a/drivers/net/vxge/vxge-main.c
> +++ b/drivers/net/vxge/vxge-main.c
> @@ -4120,6 +4120,7 @@ int vxge_fw_upgrade(struct vxgedev *vdev, char
> *fw_name, int override)
>  	       "hotplug event.\n");
> 
>  out:
> +	release_firmware(fw);
>  	return ret;
>  }
Thanks!

Acked-by: Ram Vepa <ram.vepa@exar.com>
