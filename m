From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bna: fix performance regression
Date: Wed, 30 Jul 2014 19:10:11 -0700 (PDT)
Message-ID: <20140730.191011.2296418762448966236.davem@davemloft.net>
References: <1406644170-4693-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmody@brocade.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38471 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbaGaCKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 22:10:12 -0400
In-Reply-To: <1406644170-4693-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Tue, 29 Jul 2014 16:29:30 +0200

> The recent commit "e29aa33 bna: Enable Multi Buffer RX" is causing
> a performance regression. It does not properly update 'cmpl' pointer
> at the end of the loop in NAPI handler bnad_cq_process(). The result is
> only one packet / per NAPI-schedule is processed.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied and queued up for -stable, thanks!
