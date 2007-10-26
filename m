From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [NETNS] Oops in register_pernet_operations() with CONFIG_NET_NS=n
Date: Fri, 26 Oct 2007 17:40:19 -0600
Message-ID: <m1myu5wil8.fsf@ebiederm.dsl.xmission.com>
References: <m1bqan5cuk.fsf@ebiederm.dsl.xmission.com>
	<20071026.043155.75000997.davem@davemloft.net>
	<4721D283.4050909@bull.net>
	<20071026.045503.62376243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org, dlunev@gmail.com,
	containers@lists.osdl.org, clg@fr.ibm.com, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:42528 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763442AbXJZXlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 19:41:19 -0400
In-Reply-To: <20071026.045503.62376243.davem@davemloft.net> (David Miller's
	message of "Fri, 26 Oct 2007 04:55:03 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> Thanks for doing this.
>
> But this appears to be still discussed, so I'll give
> Denis and others another day to work out the fix they
> want to include.

At this point I think all that really needs to happen is to remove
__net_initdata.  The function attributes seem sane.  Not that
I have any problem with the complete revert either.

I will send a patch to that effect in just a moment.

Eric

