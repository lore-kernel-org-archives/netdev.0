From: David Miller <davem@davemloft.net>
Subject: Re: [patch] rtnetlink: potential ERR_PTR dereference
Date: Thu, 22 Apr 2010 15:57:49 -0700 (PDT)
Message-ID: <20100422.155749.136502434.davem@davemloft.net>
References: <20100422095327.GP29647@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, kaber@trash.net,
	ebiederm@aristanetworks.com, mitch.a.williams@intel.com,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52272
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753516Ab0DVW5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 18:57:44 -0400
In-Reply-To: <20100422095327.GP29647@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Thu, 22 Apr 2010 11:53:27 +0200

> In the original code, if rtnl_create_link() returned an ERR_PTR then that
> would get passed to rtnl_configure_link() which dereferences it.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
