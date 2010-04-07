From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v3 0/4] xfrm: add x86 CONFIG_COMPAT support
Date: Wed, 07 Apr 2010 15:45:51 +0200
Message-ID: <4BBC8C8F.9020907@trash.net>
References: <1270506431-25578-1-git-send-email-fw@strlen.de> <20100407.030850.04450543.davem@davemloft.net> <20100407133528.GD22518@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	johannes@sipsolutions.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47791 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932407Ab0DGNpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 09:45:53 -0400
In-Reply-To: <20100407133528.GD22518@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal wrote:
> David Miller <davem@davemloft.net> wrote:
>> From: Florian Westphal <fw@strlen.de>
>> Date: Tue,  6 Apr 2010 00:27:07 +0200
> 
> [..]
> 
>>> I sent a patch that solved this by adding a sys_compat_write syscall
>>> and a ->compat_aio_write() to struct file_operations to the
>>> vfs mailing list, but that patch was ignored by the vfs people,
>>> and the x86 folks did not exactly like the idea either.
>>>
>>> So this leaves three alternatives:
>>> 1 - drop the whole idea and keep the current status.
>>> 2 - Add new structure definitions (with new numbering) that would work
>>>     everywhere, keep the old ones for backwards compatibility (This
>>>     was suggested by Arnd Bergmann).

Given that there is only a quite small number of users of this
interface, that would in my opinion be the best way.

>>> 3 - apply this patch set and tell userspace to move the sendmsg() when
>>>     they want to work with xfrm on x86_64 with 32 bit userland.
>> So do we know of any xfrm netlink apps that do not use sendmsg()?
