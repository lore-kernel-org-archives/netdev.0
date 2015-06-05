From: Jaeden Amero <jaeden.amero@ni.com>
Subject: [PATCH v2 0/3] net/phy: micrel: Center FLP timing at 16ms
Date: Fri, 5 Jun 2015 14:55:27 -0500
Message-ID: <1433534130-16323-1-git-send-email-jaeden.amero@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Jaeden Amero <jaeden.amero@ni.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:36203 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751447AbbFETz4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 15:55:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In v2, we add an additional cleanup commit to make an array of strings
static const and to improve const correctness generally. We also no longer
unnecessarily initialize the result variable in
ksz9031_center_flp_timing().

Jaeden Amero (3):
  net/phy: micrel: Be more const correct
  net/phy: micrel: Comment MMD address of extended registers
  net/phy: micrel: Center FLP timing at 16ms

 drivers/net/phy/micrel.c | 56 +++++++++++++++++++++++++++++++++++-------------
 1 file changed, 41 insertions(+), 15 deletions(-)

-- 
2.1.4
