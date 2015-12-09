From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] bnxt_en: Bug fix and add tx timeout recovery.
Date: Tue, 08 Dec 2015 23:31:14 -0500 (EST)
Message-ID: <20151208.233114.1109130421722594187.davem@davemloft.net>
References: <1449620322-12961-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbbLIEbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 23:31:16 -0500
In-Reply-To: <1449620322-12961-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Tue, 8 Dec 2015 19:18:38 -0500

> Fix a bitmap declaration bug and add missing tx timeout recovery.

Patch #4 has whitespace errors, the indentation before the call
to bnxt_reset_task(bp); has a space before a TAB.
