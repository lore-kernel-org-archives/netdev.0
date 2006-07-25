From: Daniel Drake <dsd@gentoo.org>
Subject: softmac possible null deref [was: Complete report of Null dereference
 errors in kernel 2.6.17.1]
Date: Tue, 25 Jul 2006 01:01:27 +0100
Message-ID: <44C55F57.8040805@gentoo.org>
References: <1153782637.44c5536e013a4@webmail>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, w@1wt.eul,
	kernel_org@digitalpeer.com, security@kernel.org,
	Netdev list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta09-winn.ispmail.ntl.com ([81.103.221.49]:53758 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932335AbWGXXxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 19:53:52 -0400
To: Tom Walter Dillig <tdillig@stanford.edu>
In-Reply-To: <1153782637.44c5536e013a4@webmail>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tom Walter Dillig wrote:
> [109]
> 452 net/ieee80211/softmac/ieee80211softmac_io.c
> Possible null dereference of variable "*pkt" in function call
> (include/asm/string.h:__constant_c_and_count_memset) checked at
> (453:net/ieee80211/softmac/ieee80211softmac_io.c)

Either I'm misunderstanding, or this is bogus.

when *pkt is allocated by the various child functions (e.g. 
ieee80211softmac_disassoc_deauth), it is always checked for NULL before 
being used.

Finally, line 453 does another NULL check, so that any failures 
generated above are handled appropriately.

What is the report trying to say?

Daniel

