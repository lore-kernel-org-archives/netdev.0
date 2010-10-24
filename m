From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] vmxnet3: fix typo setting confPA
Date: Sun, 24 Oct 2010 15:43:21 -0700 (PDT)
Message-ID: <20101024.154321.242145923.davem@davemloft.net>
References: <1287720334-15469-1-git-send-email-harvey.harrison@gmail.com>
	<1287720334-15469-3-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41259
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933129Ab0JXWm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 18:42:57 -0400
In-Reply-To: <1287720334-15469-3-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Thu, 21 Oct 2010 21:05:34 -0700

> It's a le64, not a le32, typo in one place only.
> 
> Noticed by sparse:
> drivers/net/vmxnet3/vmxnet3_drv.c:2668:52: warning: incorrect type in assignment (different base types)
> drivers/net/vmxnet3/vmxnet3_drv.c:2668:52:    expected restricted __le64 [usertype] confPA
> drivers/net/vmxnet3/vmxnet3_drv.c:2668:52:    got restricted __le32 [usertype] <noident>
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied.
