From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] netconsole: don't call __netpoll_cleanup() while atomic
Date: Tue, 12 Mar 2013 06:59:32 -0400 (EDT)
Message-ID: <20130312.065932.948546984117726324.davem@redhat.com>
References: <1362997308-5834-1-git-send-email-vfalico@redhat.com>
	<20130311113856.GC12682@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, netdev@vger.kernel.org, amwang@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933Ab3CLK73 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 06:59:29 -0400
In-Reply-To: <20130311113856.GC12682@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 11 Mar 2013 07:38:56 -0400

> On Mon, Mar 11, 2013 at 11:21:48AM +0100, Veaceslav Falico wrote:
>> __netpoll_cleanup() is called in netconsole_netdev_event() while holding a
>> spinlock. Release/acquire the spinlock before/after it and restart the
>> loop. Also, disable the netconsole completely, because we won't have chance
>> after the restart of the loop, and might end up in a situation where
>> nt->enabled == 1 and nt->np.dev == NULL.
>> 
>> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
 ...
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
