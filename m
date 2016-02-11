From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] be2net: don't report EVB for older
 chipsets when SR-IOV is disabled
Date: Thu, 11 Feb 2016 11:35:52 -0500 (EST)
Message-ID: <20160211.113552.101945405195587420.davem@davemloft.net>
References: <1455190946-2906-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@broadcom.com,
	ajit.khaparde@broadcom.com, padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbcBKQf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 11:35:56 -0500
In-Reply-To: <1455190946-2906-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Thu, 11 Feb 2016 12:42:26 +0100

> The EVB (virtual bridge) functionality should be disabled on older BE3
> and Lancer chips if SR-IOV is disabled in the NIC's BIOS. This setting
> is identified by the zero value of total VFs reported by the card.
> The GET_HSW_CONFIG command cannot be used as it is not supported by
> these older chipset's FW.
> 
> v2: added the comment
> 
> Cc: Sathya Perla <sathya.perla@broadcom.com>
> Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
> Cc: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>
> Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Cc: Somnath Kotur <somnath.kotur@broadcom.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks.
