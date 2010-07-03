From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] qlge: fix a eeh handler to not add a pending timer
Date: Fri, 02 Jul 2010 21:59:31 -0700 (PDT)
Message-ID: <20100702.215931.226773854.davem@davemloft.net>
References: <e687077281d05d3a2da49431b7c0ff0b1076f3e6.1277936929.git.root@sanx1002.austin.ibm.com>
	<e687077281d05d3a2da49431b7c0ff0b1076f3e6.1277936929.git.root@sanx1002.austin.ibm.com>
	<3d4d609f65c74c269e056c5fbe2fe4b174023059.1277936929.git.root@sanx1002.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48989
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751441Ab0GCE7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 00:59:17 -0400
In-Reply-To: <3d4d609f65c74c269e056c5fbe2fe4b174023059.1277936929.git.root@sanx1002.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Thu,  1 Jul 2010 10:00:18 -0300

> On some ocasions the function qlge_io_resume() tries to add a
> pending timer, which causes the system to hit the BUG() on
> add_timer() function.
> 
> This patch removes the timer during the EEH recovery.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
