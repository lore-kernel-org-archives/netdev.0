From: Andrew Morton <akpm@osdl.org>
Subject: Re: What is current sundance.c status
Date: Wed, 11 Oct 2006 19:55:40 -0700
Message-ID: <20061011195540.06b2ef13.akpm@osdl.org>
References: <004301c6eda6$437ac070$2d32fea9@icplus.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:43997 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422637AbWJLCzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 22:55:54 -0400
To: "Jesse Huang" <jesse@icplus.com.tw>
In-Reply-To: <004301c6eda6$437ac070$2d32fea9@icplus.com.tw>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Oct 2006 10:29:37 +0800
"Jesse Huang" <jesse@icplus.com.tw> wrote:

>     Would you tell me what is the current IP100A status? Should I re-generate patches again. Would it put into kernel or not?

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

