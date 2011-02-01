From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] net: dcb: use _safe() version of list
 iterators
Date: Mon, 31 Jan 2011 20:42:14 -0800 (PST)
Message-ID: <20110131.204214.71133534.davem@davemloft.net>
References: <20110131220048.29758.22379.stgit@jf-dev1-dcblab>
	<20110131220054.29758.20521.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59771
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751789Ab1BAEli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 23:41:38 -0500
In-Reply-To: <20110131220054.29758.20521.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 31 Jan 2011 14:00:54 -0800

> Use _safe() version of list iterator macros in dcb_setapp().
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Why?  It's unnecessary overhead, since we always branch to "out", and
therefore out of the list traversal loop, any time we list_del()
something on the list.
