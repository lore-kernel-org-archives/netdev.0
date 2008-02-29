From: Marcela Maslanova <mmaslano@redhat.com>
Subject: [PATCH] ALGO_NAME unused
Date: Fri, 29 Feb 2008 08:34:10 +0100
Message-ID: <47C7B572.6090009@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080009070309000400070209"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52163 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873AbYB2HeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 02:34:12 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m1T7YBpX020012
	for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 02:34:11 -0500
Received: from pobox.stuttgart.redhat.com (pobox.stuttgart.redhat.com [172.16.2.10])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m1T7YAFO005508
	for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 02:34:11 -0500
Received: from caladan.englab.brq.redhat.com (caladan.englab.brq.redhat.com [10.34.32.66])
	by pobox.stuttgart.redhat.com (8.13.1/8.13.1) with ESMTP id m1T7YASi025635
	for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 02:34:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080009070309000400070209
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit

I found out when I was writing manual page, that options ALGO_NAME and 
ALGO_KEY aren't used. If it's a bug or should it be remove it, as I did?

-- 
Marcela Maslanova
BaseOS team Brno


--------------080009070309000400070209
Content-Type: text/x-patch;
 name="xfrm.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="xfrm.patch"

2bb7a12809dd5f8130c172ce79dbb74f618a9d01
 ip/xfrm_state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 0e21203..93b4a2a 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -88,7 +88,7 @@ static void usage(void)
         fprintf(stderr, "ENCAP-TYPE := espinudp | espinudp-nonike\n");
 
 	fprintf(stderr, "ALGO-LIST := [ ALGO-LIST ] | [ ALGO ]\n");
-	fprintf(stderr, "ALGO := ALGO_TYPE ALGO_NAME ALGO_KEY\n");
+	fprintf(stderr, "ALGO := ALGO_TYPE\n");
 	fprintf(stderr, "ALGO_TYPE := [ ");
 	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_CRYPT));
 	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_AUTH));

--------------080009070309000400070209--
