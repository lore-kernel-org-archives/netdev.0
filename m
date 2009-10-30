From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 5/6] bond: Implement a basic set of rtnl link ops
Date: Fri, 30 Oct 2009 02:23:31 -0700
Message-ID: <m1eiols0a4.fsf@fess.ebiederm.org>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
	<1256861906-5059-5-git-send-email-ebiederm@xmission.com>
	<4AEAA403.7080204@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33168 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756591AbZJ3JXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 05:23:30 -0400
In-Reply-To: <4AEAA403.7080204@trash.net> (Patrick McHardy's message of "Fri\, 30 Oct 2009 09\:29\:55 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> Eric W. Biederman wrote:
>> +static struct rtnl_link_ops bond_link_ops __read_mostly = {
>> +	.kind		= "bond",
>> +	.setup		= bond_setup,
>> +	.validate	= bond_validate,
>> +};
>
> One more thing - you need to initialize .priv_size here so
> the devices created through rtnl_link have enough private
> room allocated.

Wow and the code works when I test it without that ouch!

As for rtnl_link_register it always succeeds so let's just
remove the return code and call it good.

Eric

