From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/1] drivers/net: fix eisa_driver probe section mismatch
Date: Fri, 11 Dec 2015 19:44:44 -0500 (EST)
Message-ID: <20151211.194444.1491517215288786662.davem@davemloft.net>
References: <1449596185-5339-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999AbbLLAoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 19:44:46 -0500
In-Reply-To: <1449596185-5339-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Frederick <fabf@skynet.be>
Date: Tue,  8 Dec 2015 18:36:25 +0100

> Some eisa_driver structures use __init probe functions which generates
> a warning and could crash if function is called after being deleted.

I can't apply this to my networking tree because you included
SCSI changes in it.
