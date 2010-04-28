From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next-2.6] net: disallow to use net_assign_generic externally
Date: Tue, 27 Apr 2010 17:02:52 -0700
Message-ID: <m1pr1k5tqr.fsf@fess.ebiederm.org>
References: <20100423114046.GC2853@psychotron.lab.eng.brq.redhat.com>
	<20100427.154918.45129593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jpirko@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51939 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394Ab0D1AC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 20:02:57 -0400
In-Reply-To: <20100427.154918.45129593.davem@davemloft.net> (David Miller's message of "Tue\, 27 Apr 2010 15\:49\:18 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Jiri Pirko <jpirko@redhat.com>
> Date: Fri, 23 Apr 2010 13:40:47 +0200
>
>> Now there's no need to use this fuction directly because it's handled by
>> register_pernet_device. So to make this simple and easy to understand,
>> make this static to do not tempt potentional users.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
> Looks reasonable, applied thanks Jiri.

Agreed (apologies for not replying sooner I lost track of this one).

It looks like having that having a choice on how to implement things
simply lead to bugs.

Eric

