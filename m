From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dev_change_name: ignore changes to same name
Date: Fri, 26 Oct 2007 03:53:52 -0700 (PDT)
Message-ID: <20071026.035352.114927735.davem@davemloft.net>
References: <20071024064445.52b1e84e@shemminger-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39692
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751413AbXJZKxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 06:53:50 -0400
In-Reply-To: <20071024064445.52b1e84e@shemminger-laptop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 24 Oct 2007 06:44:45 -0700

> Prevent error/backtrace from dev_rename() when changing
> name of network device to the same name. This is a common
> situation with udev and other scripts that bind addr to device.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Fair enough, applied.
