From: Matthew Gerlach <mgerlach@opensource.altera.com>
Subject: Re: [Nios2-dev] [PATCH net-next 0/2] Altera TSE with no PHY
Date: Fri, 10 Oct 2014 20:46:47 +0000
Message-ID: <1412974007001.77871@opensource.altera.com>
References: <1412359741-8423-1-git-send-email-walter@vanguardiasur.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"tobias.klauser@gmail.com" <tobias.klauser@gmail.com>,
	"vbridgers2013@gmail.com" <vbridgers2013@gmail.com>,
	"nios2-dev@lists.rocketboards.org" <nios2-dev@lists.rocketboards.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"guido@vanguardiasur.com.ar" <guido@vanguardiasur.com.ar>
To: Walter Lozano <walter@vanguardiasur.com.ar>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0070.outbound.protection.outlook.com ([157.56.111.70]:29168
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751851AbaJJVCj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 17:02:39 -0400
In-Reply-To: <1412359741-8423-1-git-send-email-walter@vanguardiasur.com.ar>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Walter,

I've examined your patch, and it makes sense to me.  I tested your patch again the TSE example design, and it did not break anything.

Thanks,
Matthew Gerlach
________________________________________
From: nios2-dev-bounces@lists.rocketboards.org <nios2-dev-bounces@lists.rocketboards.org> on behalf of Walter Lozano <walter@vanguardiasur.com.ar>
Sent: Friday, October 3, 2014 11:08 AM
To: netdev@vger.kernel.org
Cc: f.fainelli@gmail.com; tobias.klauser@gmail.com; vbridgers2013@gmail.com; nios2-dev@lists.rocketboards.org; davem@davemloft.net; guido@vanguardiasur.com.ar
Subject: [Nios2-dev] [PATCH net-next 0/2] Altera TSE with no PHY

In some scenarios there is no PHY chip present, for example in optical links.
This serie of patches moves PHY get addr and MDIO create to a new function and
avoids PHY and MDIO probing in these cases.

Walter Lozano (2):
  Altera TSE: Move PHY get addr and MDIO create
  Altera TSE: Add support for no PHY

 drivers/net/ethernet/altera/altera_tse_main.c |   65 +++++++++++++++++--------
 1 file changed, 44 insertions(+), 21 deletions(-)

--
1.7.10.4

_______________________________________________
Nios2-dev mailing list
Nios2-dev@lists.rocketboards.org
http://lists.rocketboards.org/cgi-bin/mailman/listinfo/nios2-dev
