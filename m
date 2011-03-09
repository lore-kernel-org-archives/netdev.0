From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] if_link: Add PORT_REQUEST_MAX
Date: Wed, 09 Mar 2011 12:49:16 -0800 (PST)
Message-ID: <20110309.124916.183062823.davem@davemloft.net>
References: <20110309203431.21853.21864.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roprabhu@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38332
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751062Ab1CIUsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 15:48:38 -0500
In-Reply-To: <20110309203431.21853.21864.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>
Date: Wed, 09 Mar 2011 12:34:31 -0800

> From: Roopa Prabhu <roprabhu@cisco.com>
> 
> This patch adds __PORT_REQUEST_MAX to port request enumeration. And defines
> PORT_REQUEST_MAX.
> 
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>

Why?

If some new request types get added, this max value will increase and
we don't want that to happen for things exposed to userspace.

Userspace should really not depend upon how many requests there are.
