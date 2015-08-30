From: Punit Vara <punitvara-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] 	man2: adjtimex.2 : add info about Clock source
Date: Sun, 30 Aug 2015 17:20:57 +0530
Message-ID: <1440935457-16478-1-git-send-email-punitvara@gmail.com>
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Punit Vara <punitvara-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

	This is a patch to the adjtimex.2 file that add more
	detail about clock source in man page which is asked to be fixed.
	I got this information from standard document RFC5909 which is
	available at https://tools.ietf.org/html/rfc5905#appendix-A.5.5.1
Signed-off-by: Punit Vara <punitvara-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 man2/adjtimex.2 | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/man2/adjtimex.2 b/man2/adjtimex.2
index 04b53b1..77b4e30 100644
--- a/man2/adjtimex.2
+++ b/man2/adjtimex.2
@@ -276,8 +276,28 @@ Mode (0 = Phase Locked Loop, 1 = Frequency Locked Loop; read-only).
 .\" commit eea83d896e318bda54be2d2770d2c5d6668d11db
 .\" Author: Roman Zippel <zippel-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
 Clock source (0 = A, 1 = B; read-only).
-.\" FIXME It would be helpful to have some explanation of what
-.\"       "Clock source" is.
+Clock source is used to synchronized the time.It can be any standard clock 
+sources like :
+
+Geosynchronous Orbit Environment Satellite
+Global Position System
+Galileo Positioning System
+Generic pulse-per-second
+Inter-Range Instrumentation Group
+LF Radio WWVB Ft. Collins, CO 60 kHz
+LF Radio DCF77 Mainflingen, DE 77.5 kHz
+LF Radio HBG Prangins, HB 75 kHz 
+LF Radio MSF Anthorn, UK 60 kHz
+LF Radio JJY Fukushima, JP 40 kHz, Saga, JP 60 kHz
+MF Radio LORAN C station, 100 kHz
+MF Radio Allouis, FR 162 kHz
+HF Radio CHU Ottawa, Ontario
+HF Radio WWV Ft. Collins, CO
+HF Radio WWVH Kauai, HI
+NIST telephone modem
+NIST telephone modem
+USNO telephone modem
+European telephone modem
 .PP
 Attempts to set read-only
 .I status
-- 
2.5.1

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
