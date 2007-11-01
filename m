From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] - e1000_ethtool.c - convert macros to functions
Date: Thu, 01 Nov 2007 14:29:17 -0700
Message-ID: <472A452D.7080208@intel.com>
References: <1193951813.17956.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	netdev <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net, Jeff Garzik <jgarzik@pobox.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27409 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754636AbXKAVfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 17:35:41 -0400
In-Reply-To: <1193951813.17956.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> Minimal macro to function conversion in e1000_ethtool.c
> 
> Adds functions reg_pattern_test and reg_set_and_check
> Changes REG_PATTERN_TEST and REG_SET_AND_CHECK macros
> to call these functions.
> 
> Saves ~2.5KB
> 
> Compiled x86, untested (no hardware)
> 
> old:
> 
> $ size drivers/net/e1000/e1000_ethtool.o
>    text    data     bss     dec     hex filename
>   16778       0       0   16778    418a drivers/net/e1000/e1000_ethtool.o
> 
> new:
> 
> $ size drivers/net/e1000/e1000_ethtool.o
>    text    data     bss     dec     hex filename
>   14128       0       0   14128    3730 drivers/net/e1000/e1000_ethtool.o
> 
> Signed-off-by: Joe Perches <joe@perches.com>



ok, looks good and it'll get tested with the e1000e version.

Thanks

Auke
