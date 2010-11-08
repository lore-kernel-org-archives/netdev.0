From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] qlge: Add firmware info to ethtool get
 regs.
Date: Mon, 08 Nov 2010 13:49:32 -0800 (PST)
Message-ID: <20101108.134932.116391208.davem@davemloft.net>
References: <1288191507-1994-1-git-send-email-ron.mercer@qlogic.com>
	<20101108.134302.102548897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jitendra.kalsaria@qlogic.com,
	ying.lok@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57396
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755622Ab0KHVtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 16:49:08 -0500
In-Reply-To: <20101108.134302.102548897.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 08 Nov 2010 13:43:02 -0800 (PST)

> From: Ron Mercer <ron.mercer@qlogic.com>
> Date: Wed, 27 Oct 2010 07:58:26 -0700
> 
>> By default we add firmware information to ethtool get regs.
>> Optionally firmware info can instead be sent to log.
>> 
>> Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
>> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> 
> Applied.

Nevermind, reverted, can you please more carefully build test
your changes?

drivers/net/qlge/qlge_mpi.c:90:12: error: static declaration of 'ql_soft_reset_mpi_risc' follows non-static declaration
drivers/net/qlge/qlge.h:2224:5: note: previous declaration of 'ql_soft_reset_mpi_risc' was here

The line that added the extern declaration to qlge.h seems to be completely
unrelated to the rest of the patch, as if it's a mis-commit or something
from another change you were working on.
