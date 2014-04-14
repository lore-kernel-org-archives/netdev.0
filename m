From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net v2 0/2] at86rf230: various fixes
Date: Mon, 14 Apr 2014 18:48:00 +0200
Message-ID: <1397494082-9394-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, phoebe.buckheister@itwm.fraunhofer.de,
	werner@almesberger.net, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:41526 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755651AbaDNQsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 12:48:16 -0400
Received: by mail-ee0-f52.google.com with SMTP id e49so6857208eek.11
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 09:48:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I currently working on a big cleanup for the at86rf230 and I detect some bugs
in the current implementation. I will send patch stacks if net-next is open
again.

It's funny to find the forgotten shift and mask in the __at86rf230_read_subreg
function but it only makes trouble if csma is activated that's why it still works
before for me.

- Alex

changes since v2:
 - correct a few text corrections (Werner helped me there, thanks!)
 - Add Reviewed by Werner Almesberger

Alexander Aring (2):
  at86rf230: remove check if AVDD settled
  at86rf230: fix __at86rf230_read_subreg function

 drivers/net/ieee802154/at86rf230.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

-- 
1.9.2
