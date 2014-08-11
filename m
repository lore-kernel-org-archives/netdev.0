From: Roy Marples <roy@marples.name>
Subject: Re: [PATCH] ipv6: do not add link-local address if one already exists
Date: Mon, 11 Aug 2014 00:05:13 +0000
Message-ID: <c612bb8cad5480b08919e32f39c6d6ea@mail.marples.name>
References: <d630f87aa617098553c3a3361fcf50aa@mail.marples.name>
 <1407703032.2161.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"\"David S. Miller\\" <davem@davemloft.net>,
	Alexey Kuznetsov "\"\"" <kuznet@ms2.inr.ac.ru>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"\"Patrick"@marples.name, McHardy@marples.name,
	" <kaber@trash.net>"@marples.name
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uberserver.marples.name ([77.75.106.61]:56121 "EHLO
	mail.marples.name" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689AbaHKAFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2014 20:05:16 -0400
In-Reply-To: <1407703032.2161.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On 2014-08-10 20:37, Hannes Frederic Sowa wrote:
> On So, 2014-08-10 at 19:56 +0000, Roy Marples wrote:
>> Currently the kernel will always add an IPv6 link-local address
>> based on the hardware address when the interface is brought up.
>> This is probably based on the assumption that userland would
>> never add one before the interface is brought up.
>> 
>> However, one at least one userland application (dhcpcd) does this so
>> it can implement RFC7217 which can be used for link-local addresses
>> as well.
>> 
>> Attached is a patch which checks to see if a link-local address exists
>> before indiscriminately adding one.
> 
> Please have a look at:
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=bc91b0f07ada5535427373a4e2050877bcc12218
> 
> This was recently implemented just for this specific case.

Is that tunable available in /proc or /sys?
I'm not overly keen on adding a netlink call just for that in dhcpcd, it 
would be a lot of bloat compared to the kernel patch.

Roy
