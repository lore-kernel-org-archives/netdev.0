From: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Wed, 21 Feb 2007 14:17:50 +0900
Message-ID: <45DBD5FE.5060708@cj.jp.nec.com>
References: <45375135.5050206@cj.jp.nec.com> <45DABECF.5020202@cj.jp.nec.com> <45DB1D7B.9020008@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, "Ronciak, John" <john.ronciak@intel.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:50234 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965350AbXBUFSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 00:18:07 -0500
In-Reply-To: <45DB1D7B.9020008@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thank you for your comment.

> this looks a lot better than the previous patch!! However, we already have a 
> state marker for _down_ that we should probably reuse. Can you try the attached 
> patch and see if it works for you? It's basically your patch without the added 
> remove flag and instead using the already available atomic state trackers.
> 
> If this works for you then that is great news and I'll push this patch to the 
> upstream kernel maintainers after testing.

I tested your patch and confirmed that the system didn't panic.

Please push the patch to the upstream kernel maintainers.
--
  Kenzo Iwami (k-iwami@cj.jp.nec.com)
