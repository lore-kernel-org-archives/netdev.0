From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Teach vlans to cleanup as a pernet subsystem
Date: Wed, 02 Dec 2009 22:14:07 -0800 (PST)
Message-ID: <20091202.221407.60533255.davem@davemloft.net>
References: <m1d42xrmkz.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37807
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751991AbZLCGOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 01:14:01 -0500
In-Reply-To: <m1d42xrmkz.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 02 Dec 2009 15:19:08 -0800

> 
> Take advantage of the fact that an explicit rtnl_kill_links is
> unnecessary (and skipping it improves batching), as network namespace
> exit calls dellink on all remaining virtual devices, and
> rtnl_link_unregister calls dellink on all outstanding devices in that
> network namespace.  To do this we need to leave the vlan proc
> directories in place until after network device exit time, which is
> done by using register_pernet_subsys instead of
> register_pernet_device.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, thanks Eric.
