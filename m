From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] rocker: sparse: fix dynamic allocation on
 stack warning
Date: Fri, 06 Mar 2015 22:02:47 -0500 (EST)
Message-ID: <20150306.220247.351754140593303403.davem@davemloft.net>
References: <1425686092-2836-1-git-send-email-sfeldma@gmail.com>
	<1425686092-2836-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101AbbCGDCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 22:02:49 -0500
In-Reply-To: <1425686092-2836-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Fri,  6 Mar 2015 15:54:52 -0800

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied, but that's quite a large on-stack allocation in the
kernel.

You might want to use a global per-cpu work area or something like
that.
