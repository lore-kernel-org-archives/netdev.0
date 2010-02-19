From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Fix sysctl restarts...
Date: Fri, 19 Feb 2010 15:41:40 -0800 (PST)
Message-ID: <20100219.154140.77047519.davem@davemloft.net>
References: <m14olcu7xo.fsf@fess.ebiederm.org>
	<20100219.152954.39315470.davem@davemloft.net>
	<m1ocjksssg.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40420
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751102Ab0BSXlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 18:41:24 -0500
In-Reply-To: <m1ocjksssg.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 19 Feb 2010 15:35:27 -0800

> When we I fixed the deadlock that can happen if you write to forwarding
> while removing the device.  The deadlock was fixed, the restart worked
> but I somehow missed the fact that proc_dointvec modifies state and so
> defeated the change detection.  *embarrassing*

Ok, I'll have to push these around to Linus and a couple -stable
releases.

Thanks.
