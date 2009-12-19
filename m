From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: fixing a timout error due not refreshing TX
 timers correctly
Date: Fri, 18 Dec 2009 20:35:45 -0800 (PST)
Message-ID: <20091218.203545.35041581.davem@davemloft.net>
References: <1260965365-14255-1-git-send-email-leitao@linux.vnet.ibm.com>
	<1260965365-14255-2-git-send-email-leitao@linux.vnet.ibm.com>
	<1260988410.31045.72.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35091
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756091AbZLSEfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:35:44 -0500
In-Reply-To: <1260988410.31045.72.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 16 Dec 2009 10:33:30 -0800

> 
> On Wed, 2009-12-16 at 04:09 -0800, leitao@linux.vnet.ibm.com wrote:
>> When running the following script on an active bnx2 interface:
>> 
>> while(true); do ifconfig ethX mtu 9000; ifconfig ethX mtu 1500; done
>> 
>> A timeout error appears and dumps the following stack:
>> 
>> NETDEV WATCHDOG: eth4 (bnx2): transmit queue 0 timed out
>> ------------[ cut here ]------------
>> Badness at net/sched/sch_generic.c:261
>> <snip>
>> 
>> This patch just fixes the way that ->trans_start is refreshed.
>> 
>> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> 
> Thanks.  Acked-by: Michael Chan <mchan@broadcom.com>

Applied, thanks everyone.
