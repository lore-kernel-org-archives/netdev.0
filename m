From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] net neigh: Decouple per interface
 neighbour table controls from binary sysctls
Date: Tue, 16 Feb 2010 15:55:55 -0800 (PST)
Message-ID: <20100216.155555.218061146.davem@davemloft.net>
References: <m1fx54kkyo.fsf@fess.ebiederm.org>
	<m1bpfskkwo.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46325
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932771Ab0BPXzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 18:55:40 -0500
In-Reply-To: <m1bpfskkwo.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 14 Feb 2010 05:27:03 -0800

> 
> Stop computing the number of neighbour table settings we have by
> counting the number of binary sysctls.  This behaviour was silly
> and meant that we could not add another neighbour table setting
> without also adding another binary sysctl.
> 
> Don't pass the binary sysctl path for neighour table entries
> into neigh_sysctl_register.  These parameters are no longer
> used and so are just dead code.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied.

I bet we can do even better and make it such that even
this NEIGH_VARS_MAX thing isn't needed.

Anyways, thanks for doing this work Eric.
