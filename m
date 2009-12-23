From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] tcp: Remove check in __tcp_push_pending_frames
Date: Wed, 23 Dec 2009 14:15:50 -0800 (PST)
Message-ID: <20091223.141550.112591784.davem@davemloft.net>
References: <20091209082613.19055.58864.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42915
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757210AbZLWWPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 17:15:48 -0500
In-Reply-To: <20091209082613.19055.58864.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Wed, 09 Dec 2009 13:56:13 +0530

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> tcp_push checks tcp_send_head and calls __tcp_push_pending_frames,
> which again checks tcp_send_head, and this unnecessary check is
> done for every other caller of __tcp_push_pending_frames.
> 
> Remove tcp_send_head check in __tcp_push_pending_frames and add
> the check to tcp_push_pending_frames. Other functions call
> __tcp_push_pending_frames only when tcp_send_head would evaluate
> to true.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Applied.
