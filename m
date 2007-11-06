From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Remove unneeded type cast in skb_truesize_check()
Date: Mon, 05 Nov 2007 16:33:20 -0800 (PST)
Message-ID: <20071105.163320.82203647.davem@davemloft.net>
References: <20071102191426.30464.7490.stgit@manray.1015granger.net>
	<20071102.142717.157261554.davem@davemloft.net>
	<472FAE5E.8030701@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chuck.lever@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34744
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755215AbXKFAd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 19:33:28 -0500
In-Reply-To: <472FAE5E.8030701@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 05 Nov 2007 18:59:26 -0500

> If that's truly the case, document the requirement (perhaps using
> something the compiler itself can verify) instead of using a clever
> type cast trick.

Feel free to submit such a change.

> Here's the problem with leaving these little surprises in commonly used 
> kernel headers.  Suppose the developer of a network driver or network 
> file system that uses one of these headers wants to employ static code 
> analysis to identify issues introduced by new patches to their 
> subsystem.  The tool warnings generated in kernel headers are just 
> noise, and make using such code analysis difficult.

Here's the problem with submitting patches fixing non-bugs and
removing useful assertions from kernel.  I won't apply them.

