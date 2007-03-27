From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Tue, 27 Mar 2007 16:36:20 -0700 (PDT)
Message-ID: <20070327.163620.54190045.davem@davemloft.net>
References: <20070327214754.GA11677@dag-work>
	<20070327.153025.45876618.davem@davemloft.net>
	<4609A42A.4040304@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dagriego@gmail.com, davem@davemloft.ne, netdev@vger.kernel.org
To: mhuth@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59646
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753933AbXC1Bq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 21:46:29 -0400
In-Reply-To: <4609A42A.4040304@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Huth <mhuth@mvista.com>
Date: Tue, 27 Mar 2007 16:09:30 -0700

> Actually, there are legitimate uses for this sort of API.  The patch 
> allows an administrator to kill specific connections that are in use by 
> other applications, where the close is not available, since the socket 
> is owned by another process.

Anything that wants to act as an external agent to manipulate
or terminate connections should use netfilter.
