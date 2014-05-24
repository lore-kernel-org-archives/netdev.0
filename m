From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the
 permisions of netlink messages
Date: Sat, 24 May 2014 18:34:20 -0400 (EDT)
Message-ID: <20140524.183420.1243401109564813269.davem@davemloft.net>
References: <20140522170505.64ef87a2@griffin>
	<87ioow6pt6.fsf@x220.int.ebiederm.org>
	<CA+55aFxybf=ya2RE5nzf10Km+JZ3=HqXGVCHYcteW2EVAUww+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, jbenc@redhat.com, luto@amacapital.net,
	jorge@dti2.net, vgoyal@redhat.com, ssorce@redhat.com,
	security@kernel.org, netdev@vger.kernel.org, serge@hallyn.com
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbaEXWeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 18:34:22 -0400
In-Reply-To: <CA+55aFxybf=ya2RE5nzf10Km+JZ3=HqXGVCHYcteW2EVAUww+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 23 May 2014 16:51:17 -0700

> On Fri, May 23, 2014 at 4:25 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> I have not seen consensus that what Zebra is doing makes sense to
>> support.
> 
> Eric, stop right there.
> 
> There is no "sensible to support". There is only "reality".
> 
> The thing that makes "reality" be "reality" is that it exists whether
> you like it or not, or whether you believe in it or not.
> 
> We don't break applications. Whether you like them or not is
> completely immaterial.

Agreed, we have to either implement Andy's suggestion (permission
check at connect() time for connected sockets, and at send() time for
unconnected sockets) or revert the behavioral change completely.
