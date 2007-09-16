From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] netlink: the temp variable name max is ambiguous
Date: Sun, 16 Sep 2007 16:36:50 -0700 (PDT)
Message-ID: <20070916.163650.88475186.davem@davemloft.net>
References: <1188675959178-git-send-email-crquan@gmail.com>
	<11886759682348-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cr_quan@163.com
To: crquan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55967
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753854AbXIPXgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:36:50 -0400
In-Reply-To: <11886759682348-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Cheng <crquan@gmail.com>
Date: Sun,  2 Sep 2007 03:45:58 +0800

> with the macro max provided by <linux/kernel.h>, so changed its name to a more proper one: limit
> 
> Signed-off-by: Denis Cheng <crquan@gmail.com>

Not strictly necessary because CPP knows to differentiate between
'max(' and plain 'max' when evaluating if a CPP macro should be
expanded or not.

Nonetheless, applied to net-2.6.24, thanks.
