From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] niu: introduce temp variables to avoid sparse warnings
 when swapping in-situ
Date: Sun, 17 Oct 2010 13:43:05 -0700 (PDT)
Message-ID: <20101017.134305.71116012.davem@davemloft.net>
References: <1287032353-30314-1-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36662
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932733Ab0JQUmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Oct 2010 16:42:43 -0400
In-Reply-To: <1287032353-30314-1-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Wed, 13 Oct 2010 21:59:13 -0700

> Suppress a large block of warnings like:
> drivers/net/niu.c:7094:38: warning: incorrect type in assignment (different base types)
> drivers/net/niu.c:7094:38:    expected restricted __be32 [usertype] ip4src
> drivers/net/niu.c:7094:38:    got unsigned long long
> drivers/net/niu.c:7104:17: warning: cast from restricted __be32
> ...
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks.
