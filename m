From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] CAN: Fix plain integer definitions in
 userspace header & new CAN version 20071227
Date: Thu, 27 Dec 2007 16:50:52 -0800 (PST)
Message-ID: <20071227.165052.167438890.davem@davemloft.net>
References: <477407C1.1050405@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sam@ravnborg.org, urs@isnogud.escape.de, netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53940
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752546AbXL1Aux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 19:50:53 -0500
In-Reply-To: <477407C1.1050405@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Thu, 27 Dec 2007 21:14:57 +0100

> diff -uprN -X net-2.6.25/Documentation/dontdiff net-2.6.25/include/linux/can/bcm.h export/net2625-2007-12-27/include/linux/can/bcm.h
> --- net-2.6.25/include/linux/can/bcm.h	2007-12-15 19:33:20.000000000 +0100
> +++ export/net2625-2007-12-27/include/linux/can/bcm.h	2007-12-27 20:35:54.000000000 +0100

Also, please properly root your patches in the future:

davem@sunset:~/src/GIT/net-2.6.25$ git apply --check --whitespace=error-all diff
error: net2625-2007-12-27/include/linux/can/bcm.h: No such file or directory

Thanks.
