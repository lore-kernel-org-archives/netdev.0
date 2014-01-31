From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] e100: Fix "disabling already-disabled device"
 warning
Date: Thu, 30 Jan 2014 16:27:45 -0800 (PST)
Message-ID: <20140130.162745.1556632155972070897.davem@davemloft.net>
References: <1391079064-18411-1-git-send-email-michele@acksyn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	idirectscm@aim.com
To: michele@acksyn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753390AbaAaA1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 19:27:46 -0500
In-Reply-To: <1391079064-18411-1-git-send-email-michele@acksyn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michele Baldessari <michele@acksyn.org>
Date: Thu, 30 Jan 2014 10:51:04 +0000

> In https://bugzilla.redhat.com/show_bug.cgi?id=994438 and
> https://bugzilla.redhat.com/show_bug.cgi?id=970480  we
> received different reports of e100 throwing the following
> warning:
 ...
> This patch removes pci_disable_device() from __e100_shutdown().
> pci_clear_master() is enough.
> 
> Signed-off-by: Michele Baldessari <michele@acksyn.org>
> Tested-by: Mark Harig <idirectscm@aim.com>

Can I get some Intel folks to review/ack this?

Thanks.
