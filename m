From: "Anand Kumria" <wildfire@progsoc.org>
Subject: Re: [RFC] [PATCH 2/3] adds ieee80211_regdomains support
Date: Wed, 25 Oct 2006 02:07:03 +0000 (UTC)
Message-ID: <ehmgs7$cba$1@sea.gmane.org>
References: <43e72e890610231547k3cf6c590r4abd0a6fe7965fda@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:14034 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1422732AbWJYCIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 22:08:39 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1GcYBY-0004OO-2R
	for netdev@vger.kernel.org; Wed, 25 Oct 2006 04:08:04 +0200
Received: from 88-110-175-230.dynamic.dsl.as9105.com ([88.110.175.230])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 04:08:04 +0200
Received: from wildfire by 88-110-175-230.dynamic.dsl.as9105.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 04:08:04 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Oct 2006 18:47:25 -0400, Luis R. Rodriguez wrote:

> ieee80211_regdomains
> 
> Breaks down regulatory domains into data structures which allow
> drivers to share channel and power contraints based on stack
> regulatory domain. This driver adds in-kernel support for common
> regulatory domains (such as FCC and ETSI), makes updating the

[snip]

+/* Stack regulatory domain values. Atheros seems to have started this 
+ * convention and most  hardware vendors followed their example.
+ * Although these are *very* common we allow for a hw-specific
+ * map between stack and device regdomain values. */
+enum stack_regdomain {
+	REGDOMAIN_WORLD		= 0x00, /* World compliance, minimum set */
+	REGDOMAIN_FCC		= 0x10, /* USA */
+	REGDOMAIN_IC		= 0x20, /* Canada */
+	REGDOMAIN_ETSI		= 0x30, /* Europe */
+	REGDOMAIN_SPAIN		= 0x31, /* Spain */
+	REGDOMAIN_FRANCE	= 0x32, /* France */
+	REGDOMAIN_MKK		= 0x40, /* Japan */
+};
+

Why not pick either the country name or the organisation within the country that determines the frequency guidelines?

Regards,
Anand

