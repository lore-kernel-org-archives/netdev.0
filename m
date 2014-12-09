From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: is the commit 571dcfde2371 (net-next) a proper fix?
Date: Tue, 09 Dec 2014 11:25:10 +0200
Message-ID: <1418117110.17201.52.camel@linux.intel.com>
References: <1418034200.17201.45.camel@linux.intel.com>
	 <20141208.193532.411317230886917624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: chenhc@lemote.com, peppe.cavallaro@st.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31428 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134AbaLIJZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 04:25:10 -0500
In-Reply-To: <20141208.193532.411317230886917624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-12-08 at 19:35 -0500, David Miller wrote:
> > It seems for me that commit 571dcfde2371 (stmmac: platform: fix default
> > values of the filter bins setting) is redundant (moreover, it could be a
> > cause of crash in some cases when there is no platform data defined in
> > case of CONFIG_OF).
> > 
> > In case of no OF the platform data should be provided by platform code
> > where the defaults are set. What did I miss?
> 
> You missed follow-up fix:
> 
> commit 28603d13997e2ef47f18589cc9a44553aad49c86
> Author: Huacai Chen <chenhc@lemote.com>
> Date:   Thu Nov 27 21:05:34 2014 +0800
> 
>     stmmac: platform: Move plat_dat checking earlier

Thanks, now it makes sense, indeed.

-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy
