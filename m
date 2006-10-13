From: "Jesse Huang" <jesse@icplus.com.tw>
Subject: Re: What is current sundance.c status
Date: Fri, 13 Oct 2006 09:14:30 +0800
Message-ID: <00ac01c6ee64$ef637210$2d32fea9@icplus.com.tw>
References: <004301c6eda6$437ac070$2d32fea9@icplus.com.tw> <20061011195540.06b2ef13.akpm@osdl.org>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr4.hinet.net ([168.95.4.104]:15316 "EHLO msr4.hinet.net")
	by vger.kernel.org with ESMTP id S1751438AbWJMBOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 21:14:41 -0400
To: "Andrew Morton" <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok, I will generate those again with descriptions.

Thank you!

Best Regards,
Jesse Huang.

----- Original Message ----- 
From: "Andrew Morton" <akpm@osdl.org>
To: "Jesse Huang" <jesse@icplus.com.tw>
Cc: <linux-kernel@vger.kernel.org>; <netdev@vger.kernel.org>;
<jgarzik@pobox.com>
Sent: Thursday, October 12, 2006 10:55 AM
Subject: Re: What is current sundance.c status


On Thu, 12 Oct 2006 10:29:37 +0800
"Jesse Huang" <jesse@icplus.com.tw> wrote:

>     Would you tell me what is the current IP100A status? Should I
re-generate patches again. Would it put into kernel or not?

I'm sitting on a copy of them.  I didn't send them to Jeff last time
because:

sundance-remove-txstartthresh-and-rxearlythresh.patch

 There's no description of what this patent issue is.

sundance-fix-tx-pause-bug-reset_tx-intr_handler.patch

 There's no description of the bug which got fixed, nor how this patch
 fixes it.

sundance-change-phy-address-search-from-phy=1-to-phy=0.patch

 There's a (small) possibility that this will break on hardware which
 _doesn't_ have a phy at address 0.

sundance-correct-initial-and-close-hardware-step.patch

 There's no real description of the bug which is being fixed, nor of how
 this patch fixes it.

sundance-solve-host-error-problem-in-low-performance-embedded.patch

 No description of what the "host error problem" is, nor of what causes
 it, nor of how this patch fixes it.


So generally these patches are a bit worrying, and it is hard to gauge what
their risk factor is.


