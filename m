From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH] s2io: fix uninitialized compile warning
Date: Fri, 04 Mar 2011 19:23:58 +0800
Message-ID: <4D70CBCE.4090306@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: ramkrishna.vepa@exar.com, sivakumar.subramani@exar.com,
	sreenivasa.honnur@exar.com, jon.mason@exar.com,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53138 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751999Ab1CDL0d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 06:26:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


drivers/net/s2io.c:7559: warning: =E2=80=98tcp_len=E2=80=99 may be used=
 uninitialized in this function

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 drivers/net/s2io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 39c17ce..2ad6364 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7556,7 +7556,7 @@ static int rx_osm_handler(struct ring_info *ring_=
data, struct RxD_t * rxdp)
 			 */
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 			if (ring_data->lro) {
-				u32 tcp_len;
+				u32 tcp_len =3D 0;
 				u8 *tcp;
 				int ret =3D 0;
=20
--=20
1.6.3.3
