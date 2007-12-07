From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] e1000: fix memcpy  in e1000_get_strings
Date: Fri, 07 Dec 2007 15:03:17 -0500
Message-ID: <4759A705.5070309@garzik.org>
References: <20071205195729.6859.97796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 12o3l@tiscali.nl
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40148 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751883AbXLGUDU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 15:03:20 -0500
In-Reply-To: <20071205195729.6859.97796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> From: Roel Kluin <12o3l@tiscali.nl>
> 
> drivers/net/e1000/e1000_ethtool.c:113:
> #define E1000_TEST_LEN sizeof(e1000_gstrings_test) / ETH_GSTRING_LEN
> 
> drivers/net/e1000e/ethtool.c:106:
> #define E1000_TEST_LEN sizeof(e1000_gstrings_test) / ETH_GSTRING_LEN
> 
> E1000_TEST_LEN*ETH_GSTRING_LEN will expand to
> sizeof(e1000_gstrings_test) / (ETH_GSTRING_LEN * ETH_GSTRING_LEN)
> 
> A lack of parentheses around defines causes unexpected results due to
> operator precedences.
> 
> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_ethtool.c |    2 +-
>  drivers/net/e1000e/ethtool.c      |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

applied 1-2 to #upstream-fixes


