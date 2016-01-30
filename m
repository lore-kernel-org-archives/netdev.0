From: Lucas Tanure <tanure@linux.com>
Subject: Re: [PATCH 3/4] netfilter: ipv4: use preferred kernel types
Date: Sat, 30 Jan 2016 12:05:52 -0200
Message-ID: <CAJX_Q+18D3omXJRy-2CEieqhAXCwpFwwt=JiRWkozPqs4cC96g@mail.gmail.com>
References: <1454159878-20706-1-git-send-email-tanure@linux.com>
	<1454159878-20706-3-git-send-email-tanure@linux.com>
	<20160130134550.GA5613@macbook.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33412 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbcA3OFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 09:05:53 -0500
In-Reply-To: <20160130134550.GA5613@macbook.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 30, 2016 at 11:45 AM, Patrick McHardy <kaber@trash.net> wrote:
> On 30.01, Lucas Tanure wrote:
>> As suggested by checkpatch.pl:
>> CHECK: Prefer kernel type 'uX' over 'uintX_t'
>
> You might have noticed we have literally hundreds of them spread over 100
> files in the netfilter code. We'll gradually change them when the code is
> touched anyways.
>
>>  net/ipv4/netfilter/ip_tables.c | 5 ++---
>>  1 file changed, 2 insertions(+), 3 deletions(-)

Yes, I checked that. But would be better to change that now?
Because:
- could take years to anyone to touch the code, as the code already
works very well
- be more standardized could facilitate reading the code
- It's a good way to encourage new people to contribute to the code

Thanks!
