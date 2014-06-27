From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next v2 0/5] dp83640: Increase support perout pins
Date: Fri, 27 Jun 2014 12:05:28 +0200
Message-ID: <1403863533-27675-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:33178 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753158AbaF0KGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 06:06:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series increases the number of periodic output pins supporte=
d
on the dp83640 to 7, and allows for reprogramming the calibration pin.

Changes since v1:
  Add dp83640 calibration pin constraints
  Fix codingstyle

Stefan S=C3=B8rensen (5):
  dp83640: Program pulsewidth2 values of perout triggers 0 and 1
  dp83640: Increase supported perout pins to 7
  dp83640: Verify calibration pin assignment
  dp83640: Get calibration pin with ptp_find_pin
  ptp: Allow reassigning calibration pin function

 drivers/net/phy/dp83640.c | 39 +++++++++++++++++++++++++++++----------
 drivers/ptp/ptp_chardev.c |  9 ++-------
 2 files changed, 31 insertions(+), 17 deletions(-)

--=20
1.9.3
