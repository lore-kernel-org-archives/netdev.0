From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] net: use helpers to access mc list
Date: Tue, 2 Feb 2010 17:31:08 +0100
Message-ID: <20100202163107.GC2601@psychotron.lab.eng.brq.redhat.com>
References: <20100126145738.GA2537@psychotron.lab.eng.brq.redhat.com>
 <20100202.072533.52179643.davem@davemloft.net>
 <20100202160347.GB2601@psychotron.lab.eng.brq.redhat.com>
 <20100202.080601.255528829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20652 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752626Ab0BBQbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2010 11:31:10 -0500
Content-Disposition: inline
In-Reply-To: <20100202.080601.255528829.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 02, 2010 at 05:06:01PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Tue, 2 Feb 2010 17:03:48 +0100
>
>> You mean "struct dev_mc_list"? But that would solve nothing. If I would still
>> use current structure in drivers, then still the migration to struct_hw_addr
>> would be all-at-once for all drivers :( This patch was exacly made to avoid
>> this.
>
>I think changing the iterator type will have to be done
>wholesale in one changeset, there is no reasonable way
>to avoid it.

So what you are proposing is to change drivers' code to use macro to iterate
through lists as step n1 and then change the iterator type as step n2 right?

If we would use my patch, we would have this done in single step. But I understand
that a kind of ugliness patch introduces is simply not acceptable not even for a
short time period, right?

Thanks

Jirka
