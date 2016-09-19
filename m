From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 09/10] bnxt_en: Support for "ethtool -r" command
Date: Mon, 19 Sep 2016 08:27:38 +0000
Message-ID: <BL2PR07MB23060AC65DF1DD370DD086DF8DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
 <1474271889-8229-10-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0073.outbound.protection.outlook.com ([104.47.36.73]:32230
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755250AbcISI1l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 04:27:41 -0400
In-Reply-To: <1474271889-8229-10-git-send-email-michael.chan@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Restart autoneg if autoneg is enabled.

> +	if (!(link_info->autoneg & BNXT_AUTONEG_SPEED))
> +		return -EINVAL;

Looks like a lot of the of implementations of this ethtool
are unconditionally doing the reset.
Perhaps the right thing to do is check for autoneg availability
at the ethtool core itself?

[Not an objection to this patch in any way as there are tens
of implementations doing the same; Simply noting this]
