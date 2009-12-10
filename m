From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: export the number of times the recv queue was full
Date: Thu, 10 Dec 2009 13:49:05 -0800 (PST)
Message-ID: <20091210.134905.232902889.davem@davemloft.net>
References: <20091210210920.6820.12664.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43366
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761745AbZLJVs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 16:48:59 -0500
In-Reply-To: <20091210210920.6820.12664.stgit@paris.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Paris <eparis@redhat.com>
Date: Thu, 10 Dec 2009 16:09:20 -0500

>   10: D7E70B0A:0016 E4E70B0A:E0BD 01 00000000:00000000 02:000AF288 00000000     0        0 12598 4 ffff88003e4c1e00 20 3 17 5 -1 0
>   11: 0100007F:2710 0100007F:B91D 01 00000000:000113DA 02:000AEFA6 00000000     0        0 12592 2 ffff88003e7b2800 20 11 0 2 -1 8

People parse these lines, it's therefore a userspace API and you
therefore cannot change their layout or add new fields to them.
