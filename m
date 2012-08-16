From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] sctp: fix compile issue with disabled CONFIG_NET_NS
Date: Thu, 16 Aug 2012 13:00:05 -0700
Message-ID: <87393m38vu.fsf@xmission.com>
References: <20120816112449.GA17354@uweber-WS> <87fw7m64v9.fsf@xmission.com>
	<1345145802.2832.6.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ulrich Weber <ulrich.weber@sophos.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36730 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933218Ab2HPUEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 16:04:30 -0400
In-Reply-To: <1345145802.2832.6.camel@bwh-desktop.uk.solarflarecom.com> (Ben
	Hutchings's message of "Thu, 16 Aug 2012 20:36:42 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:

> On Thu, 2012-08-16 at 11:58 -0700, Eric W. Biederman wrote:
>> Ulrich Weber <ulrich.weber@sophos.com> writes:
>> 
>> > struct seq_net_private has no struct net
>> > if CONFIG_NET_NS is not enabled
>> 
>> My mistake.
>> 
>> Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> 
>> > Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
>> 
>> Ulrich do you get any performance advantage by disabling the network
>> namespace?
>> 
>> I am wondering if there is any benefit to keeping it possible to disable
>> the network namespace?
>> 
>> The original reason for the option was so that distributions and
>> other who wanted to avoid new code could protect their users, and
>> that reasons seems to have long since passed.
> [...]
>
> Network namespaces are now used by common applications such as Chrome/
> Chromium and vsftpd (which flushed out some of the early implementation
> problems).  They undoubtedly have some overhead that some users would
> like to avoid, but I wouldn't expect distributions to disable the
> option.

When the network namespace code was merged we could not mearsure the
overhead, at least not on gigabit ethernet.  And there is very little
code change when network namespaces go away.

So I am starting to look for people who care.  Especially for people who
can measure overhead associated with network namespaces.

Eric
