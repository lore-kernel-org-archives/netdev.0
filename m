From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/5] [VLAN]: Unclassified vlan packet
Date: Tue, 27 May 2008 19:48:09 +0200
Message-ID: <483C4959.6000709@trash.net>
References: <20080411135714.GA8137@tp64> <483B9EBE.5030703@trash.net>	 <b25c3fa70805262320h7edb4246wd017261fe7187b88@mail.gmail.com>	 <483BAA7F.6060408@trash.net> <b25c3fa70805271040qb5f5c54tb009b51acc3acd3f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59718 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754328AbYE0RsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 13:48:11 -0400
In-Reply-To: <b25c3fa70805271040qb5f5c54tb009b51acc3acd3f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> 2008/5/26 Patrick McHardy <kaber@trash.net>:
>>>> BTW, I already have a patch queued to move the VLAN tag from
>>>> skb->cb to a seperate skb member to fix the the conflict with
>>>> qdiscs (this should also allow to use vlan accel through virtual
>>>> network devices later on). So please don't resend, I'll integrate
>>>> the patch on top of this change once we find a good spot for
>>>> invalidation.
>>>>
> 
> Was that patch applied to certain tree?
> If it was, may I know what tree is it?

I'm uploading it to kernel.org now, should appear within
the next 30 minutes at:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/vlan-next-2.6.git
