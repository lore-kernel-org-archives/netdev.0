From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Driver writer hints (was [PATCH 3/4] Add ETHTOOL_[GS]PFLAGS	sub-ioctls)
Date: Fri, 10 Aug 2007 14:01:23 -0700
Message-ID: <46BCD223.6020304@hp.com>
References: <20070810202426.GA25050@havoc.gtf.org>	<20070810202630.GB25095@havoc.gtf.org> <46BCCE57.1060802@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:51994 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762485AbXHJVCA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 17:02:00 -0400
In-Reply-To: <46BCCE57.1060802@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If we are getting (retrieving) flags:
> 
>     3) Userland issues ETHTOOL_GPFLAGS, to obtain a 32-bit bitmap
> 
>     4) Userland prints out a tag returned from ETHTOOL_GSTRINGS
>        for each bit set to one in the bitmap.  If a bit is set,
>        but there is no string to describe it, that bit is ignored.
>        (i.e. a list of 5 strings is returned, but bit 24 is set)

Is that to enable "hidden" bits?  If not I'd think that emitting some 
sort of "UNKNOWN_FLAG" might help flush-out little oopses like 
forgetting a string.

rick jones

