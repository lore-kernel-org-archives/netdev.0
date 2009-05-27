From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atlx: move modinfo data from atlx.h to atl1.c
Date: Tue, 26 May 2009 20:50:30 -0700 (PDT)
Message-ID: <20090526.205030.81503746.davem@davemloft.net>
References: <20090526223350.GJ19049@ldl.fc.hp.com>
	<20090526194852.05902e41@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: achiang@hp.com, scott.scriven@hp.com, netdev@vger.kernel.org
To: jcliburn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41007
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754441AbZE0Dub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 23:50:31 -0400
In-Reply-To: <20090526194852.05902e41@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Cliburn <jcliburn@gmail.com>
Date: Tue, 26 May 2009 19:48:52 -0500

> On Tue, 26 May 2009 16:33:50 -0600
> Alex Chiang <achiang@hp.com> wrote:
> 
>> Both atl1.c and atl2.c include atlx.h, which defines some modinfo
>> stuff. But atl2.c seems like it doesn't want the modinfo data
>> from atlx.h, as it defines its own.
>> 
>> Running modinfo on atl2.ko, we get conflicting information:
 ...
>> Reported-by: Scott Scriven <scott.scriven@hp.com>
>> Signed-off-by: Alex Chiang <achiang@hp.com>
> 
> Acked-by: Jay Cliburn <jcliburn@gmail.com>

Applied to net-2.6, thanks.
