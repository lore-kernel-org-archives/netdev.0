From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH] stmmac: platform: adjust messages and move to dev level
Date: Wed, 10 Dec 2014 12:47:51 +0200
Message-ID: <1418208471.17201.56.camel@linux.intel.com>
References: <1418119153-13355-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <20141209.182837.2218983730769727387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39839 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750911AbaLJKrv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 05:47:51 -0500
In-Reply-To: <20141209.182837.2218983730769727387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-09 at 18:28 -0500, David Miller wrote:
> From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> Date: Tue,  9 Dec 2014 11:59:13 +0200
> 
> > This patch amendes error and warning messages across the platform driver. It
> > includes the following changes:
> >  - remove unneccessary message when no memory is available
> >  - change info level to warn in the validation functions
> >  - append \n to the end of messages
> >  - change pr_* macros to dev_*
> > 
> > Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> 
> This does not apply to the net-next tree, please respin.

Yeah, maybe because the fix (*) you mentioned in previos mail is not in
net-next by some reason?

(*) I refer to commit 28603d13997e2ef47f18589cc9a44553aad49c86

-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy
