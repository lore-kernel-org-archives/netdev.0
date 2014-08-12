From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/6][pull request] Intel Wired LAN Driver Updates
 2014-08-12
Date: Tue, 12 Aug 2014 14:30:34 -0700 (PDT)
Message-ID: <20140812.143034.162444580750471649.davem@davemloft.net>
References: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbaHLVag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 17:30:36 -0400
In-Reply-To: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 12 Aug 2014 01:38:21 -0700

> This series contains updates to i40e and e1000e.
> 
> Lucas provides a fix for i40e to resolve a compile issue where a header
> was missing in the #includes.
> 
> Wei Yongjun provides a fix for i40e to resolve a sparse warning, where
> a non-static function should be static.
> 
> Julia Lawall provides a fix for i40e which was found using Coccinelle,
> where there was a typo in the name of the type given to sizeof().
> 
> Rickard Strandqvist provides a fix for i40e to replace the use of
> strncpy() with strlcpy() to avoid strings that lack null termination.
> 
> Jean Sacren provides two e1000e fixes, first is a comment fix and second
> removes an excessive space character in a debug message.

Pulled, thanks Jeff.
