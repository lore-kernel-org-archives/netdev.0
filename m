From: Jiri Pirko <jiri@mellanox.com>
Subject: Re: [PATCH] net: switchdev: fix return code of fdb_dump stub
Date: Mon, 16 Nov 2015 11:17:24 +0100
Message-ID: <20151116101724.GG2220@nanopsycho.orion>
References: <5649A770.8090909@endocode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	<davem@davemloft.net>
To: Dragos Tatulea <dragos@endocode.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0087.outbound.protection.outlook.com ([157.55.234.87]:13318
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750944AbbKPKun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2015 05:50:43 -0500
Content-Disposition: inline
In-Reply-To: <5649A770.8090909@endocode.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 16, 2015 at 10:52:48AM CET, dragos@endocode.com wrote:
>rtnl_fdb_dump always expects an index to be returned by the ndo_fdb_dump op,
>but when CONFIG_NET_SWITCHDEV is off, it returns an error.
>
>Fix that by returning the given unmodified idx.
>
>A similar fix was 0890cf6cb6ab ("switchdev: fix return value of
>switchdev_port_fdb_dump in case of error") but for the CONFIG_NET_SWITCHDEV=y
>case.
>
>Fixes: 45d4122ca7cd ("switchdev: add support for fdb add/del/dump via switchdev_port_obj ops.")
>Signed-off-by: Dragos Tatulea <dragos@endocode.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
