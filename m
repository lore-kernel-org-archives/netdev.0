From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] veth: replace iflink by a dedicated symlink in sysfs
Date: Wed, 19 Aug 2015 14:38:00 +0200
Message-ID: <20150819143800.6863fa3b@griffin>
References: <87fv3ier4s.fsf@zoro.exoscale.ch>
	<1439966648-26195-1-git-send-email-vincent@bernat.im>
	<1439966648-26195-2-git-send-email-vincent@bernat.im>
	<20150819130013.1a847627@griffin>
	<87bne38oj7.fsf@zoro.exoscale.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43921 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753337AbbHSMiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 08:38:05 -0400
In-Reply-To: <87bne38oj7.fsf@zoro.exoscale.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Aug 2015 14:13:00 +0200, Vincent Bernat wrote:
> That's the main goal of this patch: advertising the peer link as
> IFLA_LINK attribute triggers an infinite loop in userland software when
> they follow iflink to discover network devices topology. iflink has
> always been the index of a lower device. If a sysfs symbolic link is not
> good enough, I can propose a new IFLA_PEER attribute instead.

This would cause regression and break applications for those of us who
started relying on the netnsid feature to match interfaces across net
name spaces.

This is tough. If you're going to do such thing, you would at least
need to also introduce IFLA_PEER_NETNSID.

 Jiri

-- 
Jiri Benc
