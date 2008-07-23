From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: Fix/rewrite packet filtering logic
Date: Tue, 22 Jul 2008 17:11:11 -0700 (PDT)
Message-ID: <20080722.171111.267353608.davem@davemloft.net>
References: <1215852774-23974-1-git-send-email-maxk@qualcomm.com>
	<4886703B.5090609@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, rusty@rustcorp.com.au, netdev@vger.kernel.org,
	sjackman@gmail.com, linuxkernel@bristyle.com,
	virtualization@lists.linux-foundation.org, borntraeger@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59682
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752782AbYGWALL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 20:11:11 -0400
In-Reply-To: <4886703B.5090609@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 22 Jul 2008 19:41:47 -0400

> looks mostly OK, but stuff like the above should be
> 
> 	(void __user *) arg
> 
> Did you check this with sparse (Documentation/sparse.txt)?

Jeff, I already added this particular patch to the tree
a week or so ago.
