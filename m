From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] rtnetlink: potential ERR_PTR dereference
Date: Thu, 22 Apr 2010 12:35:06 +0200
Message-ID: <4BD0265A.2000301@trash.net>
References: <20100422095327.GP29647@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62606 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401Ab0DVKfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 06:35:14 -0400
In-Reply-To: <20100422095327.GP29647@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter wrote:
> In the original code, if rtnl_create_link() returned an ERR_PTR then that
> would get passed to rtnl_configure_link() which dereferences it.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> Found by a static checker, and compile tested only.  :/

Looks fine to me.

Acked-by: Patrick McHardy <kaber@trash.net>
