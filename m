From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mqprio: Avoid panic if no options are provided
Date: Thu, 22 Dec 2011 22:39:09 -0500 (EST)
Message-ID: <20111222.223909.1312508260049635700.davem@davemloft.net>
References: <1324555507-10148-1-git-send-email-tgraf@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com
To: tgraf@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756342Ab1LWDjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 22:39:13 -0500
In-Reply-To: <1324555507-10148-1-git-send-email-tgraf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@redhat.com>
Date: Thu, 22 Dec 2011 13:05:07 +0100

> Userspace may not provide TCA_OPTIONS, in fact tc currently does
> so not do so if no arguments are specified on the command line.
> Return EINVAL instead of panicing.
> 
> Signed-off-by: Thomas Graf <tgraf@redhat.com>

Applied.
