From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 6/6 linux-2.6.9-rc1/2.4.28-pre2] prism54 fix
	wpa_supplicant frequency parsing
Date: Sun, 5 Sep 2004 12:37:56 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200409051237.56058.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_EyuOBgflA0PJwpo"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_EyuOBgflA0PJwpo
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-09-05 Margit Schubert-While <margitsw@t-online.de>
2004-08-22 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>

* This work fixes wpa_supplicant frequency parsing. iwlist eth0
* scan will now show channel and frequency.


Margit















--Boundary-00=_EyuOBgflA0PJwpo
Content-Type: text/x-diff; charset="us-ascii"; name="06_fix_freqparse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="06_fix_freqparse.patch"

diff -Naur linux-2.6.9rc1/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.9-rc1msw/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.9rc1/drivers/net/wireless/prism54/isl_ioctl.c	2004-09-05 10:49:37.000000000 +0200
+++ linux-2.6.9-rc1msw/drivers/net/wireless/prism54/isl_ioctl.c	2004-09-05 10:49:53.000000000 +0200
@@ -604,8 +604,8 @@
 	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, NULL);
 
 	/* Add frequency. (short) bss->channel is the frequency in MHz */
-	iwe.u.freq.m = channel_of_freq(bss->channel);
-	iwe.u.freq.e = 0;
+	iwe.u.freq.m = bss->channel;
+	iwe.u.freq.e = 6;
 	iwe.cmd = SIOCGIWFREQ;
 	current_ev =
 	    iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_FREQ_LEN);

--Boundary-00=_EyuOBgflA0PJwpo
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_EyuOBgflA0PJwpo--
