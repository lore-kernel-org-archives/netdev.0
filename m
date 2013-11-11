From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP performance regression
Date: Mon, 11 Nov 2013 08:44:36 -0800
Message-ID: <1384188276.16391.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>
	 <1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <21120.29720.673157.151074@gargle.gargle.HOWL>
	 <1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <21120.37647.979237.40802@gargle.gargle.HOWL>
	 <1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384180787.16391.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnaud Ebalard <arno@natisbad.org>, netdev@vger.kernel.org,
	Dave Taht <dave.taht@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Sujith Manoharan <sujith@msujith.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34560 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890Ab3KKQok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 11:44:40 -0500
Received: by mail-pa0-f48.google.com with SMTP id kq14so5588151pab.35
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 08:44:39 -0800 (PST)
In-Reply-To: <1384180787.16391.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-11 at 06:39 -0800, Eric Dumazet wrote:

> How following patch helps mvneta performance on current net-next tree
> for a single TCP (sending) flow ?
> 

v2 (more chance to even compile ;)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 7d99e695a110..e8211277f15d 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -172,12 +172,12 @@
 /* Various constants */
 
 /* Coalescing */
-#define MVNETA_TXDONE_COAL_PKTS		16
+#define MVNETA_TXDONE_COAL_PKTS		1
 #define MVNETA_RX_COAL_PKTS		32
 #define MVNETA_RX_COAL_USEC		100
 
 /* Timer */
-#define MVNETA_TX_DONE_TIMER_PERIOD	10
+#define MVNETA_TX_DONE_TIMER_PERIOD	1
 
 /* Napi polling weight */
 #define MVNETA_RX_POLL_WEIGHT		64
