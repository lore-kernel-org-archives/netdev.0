From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] be2net: log link status
Date: Wed, 29 Apr 2015 15:01:25 -0400 (EDT)
Message-ID: <20150429.150125.1929181206333250804.davem@davemloft.net>
References: <553FE1F4.60402@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbbD2TB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 15:01:27 -0400
In-Reply-To: <553FE1F4.60402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Tue, 28 Apr 2015 21:39:32 +0200

> The driver unlike other drivers does not log link state changes. It's
> better for an user when asynchronous link states are logged in the
> system log.
> 
> v3: Changes from v2 discarded as "not necessary"
> 
> Cc: Sathya Perla <sathya.perla@emulex.com>
> Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
> b/drivers/net/ethernet/emulex/benet/be_main.c
> index fb0bc3c..e349131 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -662,6 +662,8 @@ void be_link_status_update(struct be_adapter
> *adapter, u8 link_status)

Patch has been corrupted by your email client.

Please fix this up and resubmit.
