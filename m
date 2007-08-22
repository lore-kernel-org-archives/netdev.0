From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 failure with netconsole
Date: Wed, 22 Aug 2007 02:12:52 -0700 (PDT)
Message-ID: <20070822.021252.85821024.davem@davemloft.net>
References: <20070821225438.9493f44c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46770
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764134AbXHVJMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 05:12:53 -0400
In-Reply-To: <20070821225438.9493f44c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 21 Aug 2007 22:54:38 -0700

> Has anyone tested all this new napi stuff with netconsole?  It's pretty
> disastrous.  It immediately goes BUG in napi_enable().

Thomas Graf has found and fixed a bug in the netconsole napi
bits a few hours ago, maybe it fixes this problem?

