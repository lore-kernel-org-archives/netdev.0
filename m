From: Al Boldi <a1426z@gawab.com>
Subject: [BUG] tulip:  promisc mode not restored after suspend
Date: Thu, 7 Sep 2006 10:35:18 +0300
Message-ID: <200609071035.18217.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The tulip driver is really great, but after suspending the device, the driver 
does not restore the promisc bit when resuming from S1/S3/S4.

To work around this, an ifconfig eth0 up, on the already up device, restores 
it.

Is there an easy way to fix this?


Thanks!

--
Al
