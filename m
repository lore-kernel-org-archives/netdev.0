From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] iwlwifi: mvm: fix tof.h header guard
Date: Mon, 14 Sep 2015 10:37:28 +0200
Message-ID: <1442219848.2075.5.camel@sipsolutions.net>
References: <1442052291-2328-1-git-send-email-nicolas.iooss_linux@m4x.org>
	 (sfid-20150912_121249_388301_136F5B59)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Iooss <nicolas.iooss_linux@m4x.org>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Gregory Greenman <gregory.greenman@intel.com>,
	linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55129 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753200AbbINIhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2015 04:37:36 -0400
In-Reply-To: <1442052291-2328-1-git-send-email-nicolas.iooss_linux@m4x.org> (sfid-20150912_121249_388301_136F5B59)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-09-12 at 12:04 +0200, Nicolas Iooss wrote:
> Commit ce7929186a39 ("iwlwifi: mvm: add basic Time of Flight 
> (802.11mc
> FTM) support") created drivers/net/wireless/iwlwifi/mvm/tof.h with a
> broken header guard:
> 
>     #ifndef __tof
>     #define __tof_h__
> 
>     ...
> 
>     #endif /* __tof_h__ */
> 
> Use __tof_h__ in the first line.
> 
Thanks, I applied it to our development tree.

johannes
