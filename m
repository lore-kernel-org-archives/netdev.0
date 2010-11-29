From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: kill unused macros in head file
Date: Mon, 29 Nov 2010 09:41:26 -0800 (PST)
Message-ID: <20101129.094126.189705325.davem@davemloft.net>
References: <4CF37D22.8090307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47288
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754996Ab0K2RlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 12:41:00 -0500
In-Reply-To: <4CF37D22.8090307@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Mon, 29 Nov 2010 18:14:58 +0800

> 
> 1. SCTP_CMD_NUM_VERBS,SCTP_CMD_MAX
> These two macros have never been used for several years since v2.6.12-rc2.
> 
> 2.sctp_port_rover,sctp_port_alloc_lock
> The commit 063930 abandoned global variables of port_rover and port_alloc_lock,
> but still keep two macros to refer to them.
> So, remove them now.
> 
> commit 06393009000779b00a558fd2f280882cc7dc2008
> Author: Stephen Hemminger <shemminger@linux-foundation.org>
> Date:   Wed Oct 10 17:30:18 2007 -0700
> 
>     [SCTP]: port randomization
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied, thank you.
