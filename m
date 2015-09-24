From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phy: marvell: add link partner advertised modes
Date: Wed, 23 Sep 2015 17:01:54 -0700
Message-ID: <56033D72.70304@gmail.com>
References: <E1Zet89-0003P6-Ee@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36739 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756187AbbIXACF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 20:02:05 -0400
Received: by pacgz1 with SMTP id gz1so4654006pac.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 17:02:04 -0700 (PDT)
In-Reply-To: <E1Zet89-0003P6-Ee@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/09/15 16:07, Russell King wrote:
> Read the standard link partner advertisment registers and store it in
> phydev->lp_advertising, so ethtool can report this information to
> userspace via ethtool.  Zero it as per genphy if autonegotiation is
> disabled.  Tested with a Marvell 88E1512 PHY.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
