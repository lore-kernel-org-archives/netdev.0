From: Sumit Saxena <sumit.saxena@avagotech.com>
Subject: RE: [V6 PATCH 6/7] megaraid_sas: fix TRUE and FALSE re-define build error
Date: Fri, 12 Jun 2015 13:45:45 +0530
Message-ID: <dc59149b1904c1164abfcc567741c4e6@mail.gmail.com>
References: <1433952538-22455-1-git-send-email-Suravee.Suthikulpanit@amd.com> <1433952538-22455-7-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: msalter@redhat.com, hanjun.guo@linaro.org, al.stone@linaro.org,
	grant.likely@linaro.org, leo.duran@amd.com,
	linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org,
	linux-kernel@vger.kernel.org, linaro-acpi@lists.linaro.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
	rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com,
	will.deacon@arm.com, thomas.lendacky@amd.com,
	herbert@gondor.apana.org.au, davem@davemloft.net, arnd@arndb.de,
	Kashyap Desai <kashyap.desai@avagotech.com>,
	Uday Lingala <uday.lingala@avagotech.com>,
	vinholikatti@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:36014 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbbFLIPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 04:15:48 -0400
Received: by qkx62 with SMTP id 62so14113168qkx.3
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 01:15:48 -0700 (PDT)
In-Reply-To: <1433952538-22455-7-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Suravee Suthikulpanit [mailto:Suravee.Suthikulpanit@amd.com]
>Sent: Wednesday, June 10, 2015 9:39 PM
>To: rjw@rjwysocki.net; lenb@kernel.org; catalin.marinas@arm.com;
>will.deacon@arm.com; thomas.lendacky@amd.com;
>herbert@gondor.apana.org.au; davem@davemloft.net; arnd@arndb.de;
>kashyap.desai@avagotech.com; sumit.saxena@avagotech.com;
>uday.lingala@avagotech.com; vinholikatti@gmail.com
>Cc: msalter@redhat.com; hanjun.guo@linaro.org; al.stone@linaro.org;
>grant.likely@linaro.org; leo.duran@amd.com; linux-arm-
>kernel@lists.infradead.org; linux-acpi@vger.kernel.org; linux-
>kernel@vger.kernel.org; linaro-acpi@lists.linaro.org;
netdev@vger.kernel.org;
>linux-crypto@vger.kernel.org; Suravee Suthikulpanit
>Subject: [V6 PATCH 6/7] megaraid_sas: fix TRUE and FALSE re-define build
>error
>
>Signed-off-by: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
>Cc: Kashyap Desai <kashyap.desai@avagotech.com>
>Cc: Sumit Saxena <sumit.saxena@avagotech.com>
>Cc: Uday Lingala <uday.lingala@avagotech.com>
>---
> drivers/scsi/megaraid/megaraid_sas_fp.c | 8 ++++++++
> 1 file changed, 8 insertions(+)
>
>diff --git a/drivers/scsi/megaraid/megaraid_sas_fp.c
>b/drivers/scsi/megaraid/megaraid_sas_fp.c
>index 4f72287..e8b7a69 100644
>--- a/drivers/scsi/megaraid/megaraid_sas_fp.c
>+++ b/drivers/scsi/megaraid/megaraid_sas_fp.c
>@@ -66,7 +66,15 @@ MODULE_PARM_DESC(lb_pending_cmds, "Change
>raid-1 load balancing outstanding "
>
> #define ABS_DIFF(a, b)   (((a) > (b)) ? ((a) - (b)) : ((b) - (a)))
> #define MR_LD_STATE_OPTIMAL 3
>+
>+#ifdef FALSE
>+#undef FALSE
>+#endif
> #define FALSE 0
>+
>+#ifdef TRUE
>+#undef TRUE
>+#endif
> #define TRUE 1
>
> #define SPAN_DEBUG 0
Acked-by: Sumit Saxena <sumit.saxena@avagotech.com>

>--
>2.1.0
