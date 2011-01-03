From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: [PATCH] Typo in comments in include/linux/igmp.h
Date: Mon, 3 Jan 2011 07:25:10 -0800 (PST)
Message-ID: <868172.46833.qm@web62502.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web62502.mail.re1.yahoo.com ([69.147.75.94]:35145 "HELO
	web62502.mail.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755270Ab1ACPbv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 10:31:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

There is a typo in comments in include/linux/igmp.h:

83 #define IGMP_HOST_MEMBERSHIP_QUERY=A0 =A0 =A0 0x11=A0 =A0 /* From RF=
C1112 */
84 #define IGMP_HOST_MEMBERSHIP_REPORT=A0 =A0=A0=A00x12=A0 =A0 /* Ditto=
 */
85 #define IGMP_DVMRP=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x13=A0=
 =A0 /* DVMRP routing */
86 #define IGMP_PIM=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x14=
=A0 =A0 /* PIM routing */
87 #define IGMP_TRACE=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x15
88 #define IGMPV2_HOST_MEMBERSHIP_REPORT=A0=A0=A00x16=A0 =A0 /* V2 vers=
ion of 0x11 */
89 #define IGMP_HOST_LEAVE_MESSAGE=A0 =A0 =A0 =A0=A0=A00x17
90 #define IGMPV3_HOST_MEMBERSHIP_REPORT=A0=A0=A00x22=A0 =A0 /* V3 vers=
ion of 0x11 */

The line 88 and 90 are about REPORT messages.
The IGMP_HOST_MEMBERSHIP_REPORT value is 0x12.
So the comment on line 88 must be /* V2 version of 0x12 */,
and the comment on line 90 must be /* V3 version of 0x12 */.

Here is a patch.

Thank you,
=46rancois-Xavier Le Bail

------------------------------------

diff -ru a/include/linux/igmp.h b/include/linux/igmp.h
--- a/include/linux/igmp.h=A0=A0=A0 2010-08-27 01:47:12.000000000 +0200
+++ b/include/linux/igmp.h=A0=A0=A0 2010-12-15 09:50:47.808363144 +0100
@@ -85,9 +85,9 @@
 #define IGMP_DVMRP=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 0x13=A0=A0=A0 /* DVMRP=
 routing */
 #define IGMP_PIM=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 0x14=A0=A0=A0 /* PIM rou=
ting */
 #define IGMP_TRACE=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 0x15
-#define IGMPV2_HOST_MEMBERSHIP_REPORT=A0=A0=A0 0x16=A0=A0=A0 /* V2 ver=
sion of 0x11 */
+#define IGMPV2_HOST_MEMBERSHIP_REPORT=A0=A0=A0 0x16=A0=A0=A0 /* V2 ver=
sion of 0x12 */
 #define IGMP_HOST_LEAVE_MESSAGE =A0=A0=A0 0x17
-#define IGMPV3_HOST_MEMBERSHIP_REPORT=A0=A0=A0 0x22=A0=A0=A0 /* V3 ver=
sion of 0x11 */
+#define IGMPV3_HOST_MEMBERSHIP_REPORT=A0=A0=A0 0x22=A0=A0=A0 /* V3 ver=
sion of 0x12 */
=20
 #define IGMP_MTRACE_RESP=A0=A0=A0 =A0=A0=A0 0x1e
 #define IGMP_MTRACE=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 0x1f





     =20
