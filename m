From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] bnx2x: previous driver unload revised
Date: Tue, 27 Mar 2012 22:41:43 -0400 (EDT)
Message-ID: <20120327.224143.558320780655911930.davem@davemloft.net>
References: <1332830827-18253-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757601Ab2C1Clq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 22:41:46 -0400
In-Reply-To: <1332830827-18253-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Tue, 27 Mar 2012 08:47:07 +0200

> The flow in which the bnx2x driver starts after a previous driver 
> has been terminated in an 'unclean' manner has several bugs and
> FW risks, which makes it possible for the driver to fail after 
> boot-from-SAN or kdump.
> This patch contains a revised flow which performs a safer
> initialization, solving the possible crash scenarios.
> Notice this patch contains lines with over 80 characters, as it
> keeps print-strings in a single line.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
