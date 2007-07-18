From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen - define and use pktgen_dbg,err,warn,info
Date: Wed, 18 Jul 2007 15:49:50 -0700 (PDT)
Message-ID: <20070718.154950.91758269.davem@davemloft.net>
References: <1184796853.5863.40.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58855
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752088AbXGRWtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 18:49:51 -0400
In-Reply-To: <1184796853.5863.40.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 18 Jul 2007 15:14:13 -0700

> -#define VERSION  "pktgen v2.68: Packet Generator for packet performance testing.\n"
> +#define PKTGEN_NAME    "pktgen"
> +#define PKTGEN_VERSION "v2.68"
> +#define PKTGEN_DESC    "Packet Generator for packet performance testing"
> +#define PKTGEN_FULLINFO PKTGEN_NAME " " PKTGEN_VERSION ": " PKTGEN_DESC ".\n"
 ...

> -static char version[] __initdata = VERSION;
> -

Using PKTGEN_FULLINFO explicitly won't get that string into the
__initdata section as the version[] will, that's why people do it that
way with the explicit version[] array.

Please put it back, assign PKTGEN_FULLINFO to it, and use it.
