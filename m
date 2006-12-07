From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] convert hh_lock to seqlock
Date: Thu, 07 Dec 2006 15:07:18 -0800 (PST)
Message-ID: <20061207.150718.41636608.davem@davemloft.net>
References: <45789534.1050703@cosmosbay.com>
	<20061207145300.3a5a21a6@localhost>
	<45789D94.3050509@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33065
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1163933AbWLGXHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 18:07:15 -0500
To: dada1@cosmosbay.com
In-Reply-To: <45789D94.3050509@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 08 Dec 2006 00:02:44 +0100

> What's the problem with my suggestion of keeping hh_refcnt on
> another cache line ?  It is basically free (once your change from
> rwlock to seqlock put in), and no change of algorithm.

I think this change is worthwhile for the short term
until we get time to implement something like the RCU
idea.
