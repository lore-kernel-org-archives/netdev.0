From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make CONFIG_BQL actually end user configurable
Date: Mon, 05 Mar 2012 23:11:21 -0500 (EST)
Message-ID: <20120305.231121.191303412414457777.davem@davemloft.net>
References: <1331005096-12332-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964921Ab2CFEL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 23:11:27 -0500
In-Reply-To: <1331005096-12332-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon,  5 Mar 2012 22:38:16 -0500

> While most people will have no reason to turn this off, the
> ability to do so can be useful for testing BQL support additions
> on previously BQL-unaware drivers and similar.

It's intentionally like this.

> The kconfig help text is largely taken from the original RFC
> patchset 0/N header sent to netdev@vger.kernel.org in fall 2011.

And this it why the final version that got checked in didn't
have the help text nor the user configurability.  I asked for
it to be this way.
