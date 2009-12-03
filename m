From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/5] bnx2: Print warning when unable to allocate the
 full SKB/page ring.
Date: Thu, 3 Dec 2009 13:49:20 -0800
Message-ID: <1259876960.8991.12.camel@HP1>
References: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
 <1259869595-6450-3-git-send-email-mchan@broadcom.com>
 <20091203.130821.253017587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1334 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753299AbZLCV7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 16:59:12 -0500
In-Reply-To: <20091203.130821.253017587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2009-12-03 at 13:08 -0800, David Miller wrote:
> Applied, but I would rate limit this thing.
> 
> It could especially be problematic if this condition is
> triggered when the device is being used for netconsole.
> 

We only do the printk() during init. time if we cannot allocate buffers
for the whole ring.  printk() is not used at all during run-time.
Thanks.


