From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: don't use dev_err when AER enabling
 fails
Date: Tue, 30 Jul 2013 00:00:41 -0700 (PDT)
Message-ID: <20130730.000041.2001900161264941490.davem@davemloft.net>
References: <1374761455-28193-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58027 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab3G3HAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 03:00:44 -0400
In-Reply-To: <1374761455-28193-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Thu, 25 Jul 2013 16:10:55 +0200

> The driver uses dev_err when enabling of AER fails (e.g. PCIe AER is not
> supported). The dev_info is more appropriate to avoid console pollution.
> 
> Cc: sathya.perla@emulex.com
> Cc: subbu.seetharaman@emulex.com
> Cc: ajit.khaparde@emulex.com
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks.
