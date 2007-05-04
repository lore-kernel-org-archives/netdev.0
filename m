From: jamal <hadi@cyberus.ca>
Subject: Re: [RESEND][PATCH][XFRM] SAD info TLV aggregation
Date: Thu, 03 May 2007 21:44:56 -0400
Message-ID: <1178243096.4068.62.camel@localhost>
References: <1178233601.4068.2.camel@localhost> <463A7BF7.5010604@trash.net>
	 <1178239828.4068.52.camel@localhost>
	 <20070503.175251.122616732.davem@davemloft.net>
	 <1178240477.4068.56.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-83ZsD0WKBTu9RUjTNdNm"
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:29246 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbXEDBpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 21:45:01 -0400
Received: by wx-out-0506.google.com with SMTP id h31so615774wxd
        for <netdev@vger.kernel.org>; Thu, 03 May 2007 18:45:00 -0700 (PDT)
In-Reply-To: <1178240477.4068.56.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-83ZsD0WKBTu9RUjTNdNm
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2007-03-05 at 21:01 -0400, jamal wrote:
> On Thu, 2007-03-05 at 17:52 -0700, David Miller wrote:
> 
> > I'll sit tight and wait for the next version, whoever
> > creates it :-)
> 
> I could send you an incremental patch if that would work
> ( a 4+/- liner on the include). 
> 

i.e something along the lines of the attached ...
(so user space doesnt change)

Canucks going to survive tonight? ;->

cheers,
jamal


--=-83ZsD0WKBTu9RUjTNdNm
Content-Disposition: attachment; filename=sapd-extra
Content-Type: text/x-patch; name=sapd-extra; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 8a522d5..544613a 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -278,9 +278,9 @@ enum xfrm_sadattr_type_t {
 	XFRMA_SADUNSPEC,
 	XFRMA_SADCNT,
 	XFRMA_SADHINFO,
-	__XFRMA_SAD_MAX
+	__XFRMA_SADMAX
 
-#define XFRMA_SAD_MAX (__XFRMA_SAD_MAX - 1)
+#define XFRMA_SADMAX (__XFRMA_SADMAX - 1)
 };
 
 struct xfrmu_sadhinfo {
@@ -292,9 +292,9 @@ enum xfrm_spdattr_type_t {
 	XFRMA_SPDUNSPEC,
 	XFRMA_SPDINFO,
 	XFRMA_SPDHINFO,
-	__XFRMA_SPD_MAX
+	__XFRMA_SPDMAX
 
-#define XFRMA_SPD_MAX (__XFRMA_SPD_MAX - 1)
+#define XFRMA_SPDMAX (__XFRMA_SPDMAX - 1)
 };
 
 struct xfrmu_spdinfo {

--=-83ZsD0WKBTu9RUjTNdNm--

