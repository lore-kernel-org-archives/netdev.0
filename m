From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3] checkpatch: Add some --strict coding style checks
Date: Wed, 29 Feb 2012 21:10:22 -0800
Message-ID: <1330578622.23314.53.camel@joe2Laptop>
References: <20120229173421.GA13733@tuxdriver.com>
	 <477F20668A386D41ADCC57781B1F70430836762D55@SC-VEXCH1.marvell.com>
	 <1330542811.21491.7.camel@joe2Laptop>
	 <477F20668A386D41ADCC57781B1F70430836762D6C@SC-VEXCH1.marvell.com>
	 <1330575843.23314.52.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	Andy Whitcroft <apw@shadowen.org>,
	David Miller <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ilan Elias <ilane@ti.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Bruce W. Allen" <bruce.w.allan@intel.com>,
	Bing Zhao <bzhao@marvell.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46003 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750833Ab2CAFK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 00:10:26 -0500
In-Reply-To: <1330575843.23314.52.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-29 at 20:24 -0800, Joe Perches wrote:
> Argument alignment across multiple lines should
> match the open parenthesis.
> 
> Logical continuations should be at the end of
> the previous line, not the start of a new line.
> 
> These are not required by CodingStyle so make the
> tests active only when using --strict.
> 
> Improved_by_examples_from: "Bruce W. Allen" <bruce.w.allan@intel.com>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> V3: Use perl 5.10 features
>     Use a runtime check of perl version so $balanced_parens
>     is not used in perl versions that don't support it.
>     Update memset and min_t checks for newer $balanced_parens
>     test.
>     Improve alignment position test.
>     Add message suggesting perl upgrade.

Forgot to mention this stops a hang
in the memset tests.
