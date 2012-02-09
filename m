From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
Date: Thu, 09 Feb 2012 14:01:37 -0500 (EST)
Message-ID: <20120209.140137.825194006300440230.davem@davemloft.net>
References: <C5551D9AAB213A418B7FD5E4A6F30A0702F874CA@ORSMSX106.amr.corp.intel.com>
	<20120209.134940.176223015646381142.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F87530@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758274Ab2BITBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 14:01:42 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F87530@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Thu, 9 Feb 2012 18:57:26 +0000

> I'm sure the consternation on my part is that I had thought you
> wanted the feature bits to default to none.  You said this at one
> point:

In "the kernel", so that things like GLIBC, that don't ask for the
features, no longer break with lots of VFs.

"iproute2" in userland can set all the feature bits, and have code
added to accomodate large dump requests in the future, so you're going
to have to make changes to iproute2 for this.
