From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] be2net: log link status
Date: Wed, 22 Apr 2015 06:10:55 -0700
Message-ID: <1429708255.31675.42.camel@perches.com>
References: <1429707370-2792-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0173.hostedemail.com ([216.40.44.173]:47387 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755991AbbDVNLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 09:11:00 -0400
In-Reply-To: <1429707370-2792-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-22 at 14:56 +0200, Ivan Vecera wrote:
> The driver unlike other drivers does not log link state changes.
[]
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
[]
> @@ -662,6 +662,8 @@ void be_link_status_update(struct be_adapter *adapter, u8 link_status)
>  		netif_carrier_on(netdev);
>  	else
>  		netif_carrier_off(netdev);
> +
> +	netdev_info(netdev, "Link is %s\n", link_status ? "Up" : "Down");
>  }

If this is valuable, it's also valuable to emit the
link speed/duplex states like most other drivers.
