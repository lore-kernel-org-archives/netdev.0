From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] devlink: add missing install of header
Date: Mon, 11 Apr 2016 21:34:11 -0400 (EDT)
Message-ID: <20160411.213411.1256428350435055224.davem@davemloft.net>
References: <1460407148-24228-1-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755345AbcDLBeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 21:34:13 -0400
In-Reply-To: <1460407148-24228-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 11 Apr 2016 13:39:08 -0700

> The new devlink.h in uapi was not being installed by
> make headers_install
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks Stephen.

I wish we could just have everything under uapi/linux automatically
get this treatment, but I guess there is a very good reason for the
current behavior.
