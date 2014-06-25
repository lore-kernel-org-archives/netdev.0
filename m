From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next 0/3] dp83640: Increase support perout pins
Date: Wed, 25 Jun 2014 14:37:28 +0200
Message-ID: <1403699851-11178-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164185.static.sonofon.dk ([213.83.164.185]:59229 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752688AbaFYMhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 08:37:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series increases the number of periodic output pins supporte=
d
on the dp83640 to 7, and allows for reprogramming the calibration pin.

Stefan S=C3=B8rensen (3):
  ptp: Allow reassigning calibration pin function
  dp83640: Program pulsewidth2 values of perout triggers 0 and 1
  dp83640: Increase supported perout pins to 7

 drivers/net/phy/dp83640.c | 28 ++++++++++++++++++----------
 drivers/ptp/ptp_chardev.c |  9 ++-------
 2 files changed, 20 insertions(+), 17 deletions(-)

--=20
1.9.3
