From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net 0/3] phyter bug fixes
Date: Mon, 25 May 2015 11:55:42 +0200
Message-ID: <cover.1432547381.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Christian Riesch <christian.riesch@omicron.at>,
	Stefan Sorensen <stefan.sorensen@spectralink.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:33642 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbEYJzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 05:55:49 -0400
Received: by wgez8 with SMTP id z8so68961104wge.0
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 02:55:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While working on a project using the phyter, I noticed some bugs that
have crept in over time.  This series fixes those bugs.  These patches
are also meant for stable.

Thanks,
Richard


Richard Cochran (3):
  net: dp83640: fix broken calibration routine.
  net: dp83640: reinforce locking rules.
  net: dp83640: fix improper double spin locking.

 drivers/net/phy/dp83640.c | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

-- 
2.1.4
