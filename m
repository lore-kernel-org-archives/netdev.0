From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make /proc/net a symlink on /proc/self/net
Date: Wed, 05 Mar 2008 13:29:44 -0800 (PST)
Message-ID: <20080305.132944.68665776.davem@davemloft.net>
References: <47CE8FF7.7000701@openvz.org>
	<20080305191501.GF8728@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, adobriyan@openvz.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46544
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754381AbYCEV3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 16:29:46 -0500
In-Reply-To: <20080305191501.GF8728@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Wed, 5 Mar 2008 11:15:01 -0800

> One question below for get_proc_task_net() -- I don't see how the
> reference to a task struct is released.

Yes, it definitely seems to leak.
