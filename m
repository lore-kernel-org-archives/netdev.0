From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] sctp: fix compile issue with disabled
 CONFIG_NET_NS
Date: Thu, 16 Aug 2012 20:36:42 +0100
Message-ID: <1345145802.2832.6.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120816112449.GA17354@uweber-WS> <87fw7m64v9.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ulrich Weber <ulrich.weber@sophos.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29692 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753308Ab2HPTgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 15:36:46 -0400
In-Reply-To: <87fw7m64v9.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-16 at 11:58 -0700, Eric W. Biederman wrote:
> Ulrich Weber <ulrich.weber@sophos.com> writes:
> 
> > struct seq_net_private has no struct net
> > if CONFIG_NET_NS is not enabled
> 
> My mistake.
> 
> Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> > Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
> 
> Ulrich do you get any performance advantage by disabling the network
> namespace?
> 
> I am wondering if there is any benefit to keeping it possible to disable
> the network namespace?
> 
> The original reason for the option was so that distributions and
> other who wanted to avoid new code could protect their users, and
> that reasons seems to have long since passed.
[...]

Network namespaces are now used by common applications such as Chrome/
Chromium and vsftpd (which flushed out some of the early implementation
problems).  They undoubtedly have some overhead that some users would
like to avoid, but I wouldn't expect distributions to disable the
option.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
