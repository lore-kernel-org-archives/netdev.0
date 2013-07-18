From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] vxlan: unregister on namespace exit
Date: Thu, 18 Jul 2013 13:15:40 -0700 (PDT)
Message-ID: <20130718.131540.696001399622511523.davem@davemloft.net>
References: <20130718083826.58ae2b77@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933723Ab3GRUPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 16:15:41 -0400
In-Reply-To: <20130718083826.58ae2b77@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 18 Jul 2013 08:38:26 -0700

> Fix memory leaks and other badness from VXLAN network namespace
> teardown. When network namespace is removed, all the vxlan devices should
> be unregistered (not closed).
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
