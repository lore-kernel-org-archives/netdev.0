From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vmxnet3: make bit twiddle routines inline
Date: Thu, 21 Oct 2010 03:14:30 -0700 (PDT)
Message-ID: <20101021.031430.260084440.davem@davemloft.net>
References: <20101015140620.63d0a615@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60529
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756243Ab0JUKOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:14:07 -0400
In-Reply-To: <20101015140620.63d0a615@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 15 Oct 2010 14:06:20 -0700

> Gcc doesn't usually handle inline across compilation units, and the
> functions don't have to be global in scope. Move the set/reset flag
> functions int the existing vmxnet3 header.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
