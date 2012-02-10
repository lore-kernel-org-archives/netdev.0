From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] rtnetlink: Fix problem with buffer allocation
Date: Fri, 10 Feb 2012 14:24:52 -0500 (EST)
Message-ID: <20120210.142452.2227318248629247303.davem@davemloft.net>
References: <20120210150518.4002.85507.stgit@gitlad.jf.intel.com>
	<20120210.135151.754379087490167636.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F88CF8@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753Ab2BJTY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 14:24:57 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F88CF8@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Fri, 10 Feb 2012 19:07:15 +0000

> OK, sounds good.  How about I also add a field to indicate the
> application buffer size?

How can this help, we already have it.  It's the length field to
the recvmsg() call.

Also, either the user provided a large enough buffer or he didn't.  If
he didn't we return an error to the recvmsg() call, and the user can
increase the buffer size and try again.
