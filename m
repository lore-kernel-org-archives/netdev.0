From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnl: RTM_GETNETCONF: fix wrong return value
Date: Fri, 19 Feb 2016 15:34:28 -0500 (EST)
Message-ID: <20160219.153428.366384819428802434.davem@davemloft.net>
References: <1455676996-6335-1-git-send-email-a.s.protopopov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: a.s.protopopov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422898AbcBSUea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 15:34:30 -0500
In-Reply-To: <1455676996-6335-1-git-send-email-a.s.protopopov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Protopopov <a.s.protopopov@gmail.com>
Date: Tue, 16 Feb 2016 21:43:16 -0500

> An error response from a RTM_GETNETCONF request can return the positive
> error value EINVAL in the struct nlmsgerr that can mislead userspace.
> 
> Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>

Applied and queued up for -stable, thanks.
