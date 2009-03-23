From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: fix unaligned memory access in tcp_sack
Date: Mon, 23 Mar 2009 13:48:24 +0100
Message-ID: <49C78518.2010106@trash.net>
References: <878wmx3pfk.fsf@netris.org> <20090322.211730.224794112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mhw@netris.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37914 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936AbZCWMsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 08:48:32 -0400
In-Reply-To: <20090322.211730.224794112.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Mark H. Weaver" <mhw@netris.org>
> Date: Sun, 22 Mar 2009 23:09:51 -0400
> 
>> This patch fixes an unaligned memory access in tcp_sack while reading
>> sequence numbers from TCP selective acknowledgement options.  Prior to
>> applying this patch, upstream linux-2.6.27.20 was occasionally
>> generating messages like this on my sparc64 system:
>>
>>   [54678.532071] Kernel unaligned access at TPC[6b17d4] tcp_packet+0xcd4/0xd00
>>
>> More details provided upon request.  Apologies in advance if I've sent
>> this to the wrong place or not followed proper procedures.
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Looks good to me. Dave, please apply directly or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Thanks!
