From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] xfrm: add x86 CONFIG_COMPAT support
Date: Wed, 07 Apr 2010 16:48:42 -0700 (PDT)
Message-ID: <20100407.164842.54065324.davem@davemloft.net>
References: <20100407.030850.04450543.davem@davemloft.net>
	<20100407133528.GD22518@Chamillionaire.breakpoint.cc>
	<4BBC8C8F.9020907@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, johannes@sipsolutions.net
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48195
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756122Ab0DGXsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 19:48:39 -0400
In-Reply-To: <4BBC8C8F.9020907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 07 Apr 2010 15:45:51 +0200

> Florian Westphal wrote:
>> David Miller <davem@davemloft.net> wrote:
>>> From: Florian Westphal <fw@strlen.de>
>>> Date: Tue,  6 Apr 2010 00:27:07 +0200
>> 
>> [..]
>> 
>>>> I sent a patch that solved this by adding a sys_compat_write syscall
>>>> and a ->compat_aio_write() to struct file_operations to the
>>>> vfs mailing list, but that patch was ignored by the vfs people,
>>>> and the x86 folks did not exactly like the idea either.
>>>>
>>>> So this leaves three alternatives:
>>>> 1 - drop the whole idea and keep the current status.
>>>> 2 - Add new structure definitions (with new numbering) that would work
>>>>     everywhere, keep the old ones for backwards compatibility (This
>>>>     was suggested by Arnd Bergmann).
> 
> Given that there is only a quite small number of users of this
> interface, that would in my opinion be the best way.

Can you explain that line of reasoning?

It's not that there are only "3 or 4 tools" using these interfaces,
it's the fact that 32-bit binaries of those tools are on millions and
millions of systems out there.
