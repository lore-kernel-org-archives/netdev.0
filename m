From: David Miller <davem@davemloft.net>
Subject: Re: [patch 20/21] forcedeth: fix locking bug with netconsole
Date: Fri, 28 Mar 2008 15:43:53 -0700 (PDT)
Message-ID: <20080328.154353.43255092.davem@davemloft.net>
References: <200803282141.m2SLfUwU011858@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, mingo@elte.hu,
	aabdulla@nvidia.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33373
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753246AbYC1WoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 18:44:01 -0400
In-Reply-To: <200803282141.m2SLfUwU011858@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 28 Mar 2008 14:41:30 -0700

> From: Ingo Molnar <mingo@elte.hu>
> 
> While using netconsole on forcedeth, lockdep noticed the following locking
> bug:

Please do not mix device driver changes with core networking
changes.
