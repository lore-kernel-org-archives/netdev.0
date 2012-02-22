From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: netkey and ip statistics
Date: Wed, 22 Feb 2012 00:01:21 -0500
Message-ID: <1329886881.2788.169.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:59106 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750770Ab2BVFB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Feb 2012 00:01:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  I'm still working on adaptive traffic shaping for
percentile billing and am almost done.  However, I have a question about
byte count statistics when using netkey.

If I understand it correctly, traffic traverses an interface twice when
netkey is used for IPSec, once encrypted and once decrypted.  So let's
say I am using eth1 and transmit 999b decrypted which turns into 1000b
encrypted and I receive 2000b encrypted which turns into 1998b
decrypted.  What will ip -s link ls eth1 show for TX and RX byte counts?

TX 1000b  RX 2000b (what I am hoping for)
or
TX 999b  RX 1998b
or
TX 1999b  RX 3998b

Thanks - John
