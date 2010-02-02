From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: use helpers to access mc list
Date: Tue, 02 Feb 2010 08:06:01 -0800 (PST)
Message-ID: <20100202.080601.255528829.davem@davemloft.net>
References: <20100126145738.GA2537@psychotron.lab.eng.brq.redhat.com>
	<20100202.072533.52179643.davem@davemloft.net>
	<20100202160347.GB2601@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56908
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754120Ab0BBQFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 11:05:48 -0500
In-Reply-To: <20100202160347.GB2601@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 2 Feb 2010 17:03:48 +0100

> You mean "struct dev_mc_list"? But that would solve nothing. If I would still
> use current structure in drivers, then still the migration to struct_hw_addr
> would be all-at-once for all drivers :( This patch was exacly made to avoid
> this.

I think changing the iterator type will have to be done
wholesale in one changeset, there is no reasonable way
to avoid it.
