From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/20] net: NETDEV_UNREGISTER_PERNET ->
 NETDEV_UNREGISTER_BATCH
Date: Mon, 30 Nov 2009 15:55:24 -0800 (PST)
Message-ID: <20091130.155524.31786099.davem@davemloft.net>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
	<20091130.144917.233710214.davem@davemloft.net>
	<m1d42zoa0a.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, dlezcano@fr.ibm.com,
	adobriyan@gmail.com, kaber@trash.net, opurdila@ixiacom.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35904
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751504AbZK3XzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 18:55:18 -0500
In-Reply-To: <m1d42zoa0a.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 30 Nov 2009 15:42:13 -0800

> So it appears to me that moving the final syncrhonize_net() back
> where it was before the NETDEV_UNREGISTER_PERNET changes (as I did)
> is necessary for correctness.

Ok, it appears your right.  Thanks for the analysis.

I'll look over the rest of your series now.
