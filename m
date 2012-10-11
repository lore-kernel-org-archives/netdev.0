From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH] of/mdio: Staticise !CONFIG_OF stubs
Date: Thu, 11 Oct 2012 16:16:25 +0900
Message-ID: <20121011071623.GB11726@opensource.wolfsonmicro.com>
References: <1349843618-11209-1-git-send-email-broonie@opensource.wolfsonmicro.com>
 <20121010.223427.1187011104173761756.davem@davemloft.net>
 <20121010.223850.1856019052308947278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: srinivas.kandagatla@st.com, fengguang.wu@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:56225 "EHLO
	opensource.wolfsonmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756847Ab2JKHQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 03:16:33 -0400
Content-Disposition: inline
In-Reply-To: <20121010.223850.1856019052308947278.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 10, 2012 at 10:38:50PM -0400, David Miller wrote:

> Did you actually try to compile this?

Yup, and the kernel did actually build.

> In file included from drivers/net/phy/mdio_bus.c:29:0:
> include/linux/of_mdio.h:29:12: warning: =E2=80=98of_mdiobus_register=E2=
=80=99 defined but not used [-Wunused-function]

> I'll fix this up, but test your changes please.

I'm afraid I missed all those in among the other warnings in net/, sorr=
y
(I needed to do a full rebuild as it was a config change to fix up the
underlying error and I always build with sparse enabled which generates
a bunch of warnings in net/).
