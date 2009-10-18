From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: Optimize genl_register_family()
Date: Sat, 17 Oct 2009 23:58:01 -0700 (PDT)
Message-ID: <20091017.235801.197313260.davem@davemloft.net>
References: <20091015055453.30128.12160.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50044
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752233AbZJRG5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 02:57:39 -0400
In-Reply-To: <20091015055453.30128.12160.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Thu, 15 Oct 2009 11:24:53 +0530

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> genl_register_family() doesn't need to call genl_family_find_byid
> when GENL_ID_GENERATE is passed during register.
> 
> Patch on net-next-2.6, compile and reboot testing only.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Applied.
