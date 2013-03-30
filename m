From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] doc: packet: add minimal TPACKET_V3 example
 code
Date: Sat, 30 Mar 2013 17:40:49 -0400 (EDT)
Message-ID: <20130330.174049.775595204047285193.davem@davemloft.net>
References: <1364571389-26326-1-git-send-email-dborkman@redhat.com>
	<1364571737.5113.25.camel@edumazet-glaptop>
	<5155B82A.2050701@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, eric@regit.org,
	victor@inliniac.net
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125Ab3C3Vkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 17:40:51 -0400
In-Reply-To: <5155B82A.2050701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 29 Mar 2013 16:50:02 +0100

> On 03/29/2013 04:42 PM, Eric Dumazet wrote:
>> On Fri, 2013-03-29 at 16:36 +0100, Daniel Borkmann wrote:
>>> Lost in space for a long time, but it finally came back to us from
>>> some ancient code tombs. This patch adds a minimal runnable example
>>> of Linux' packet mmap(2) from Chetan Loke's TPACKET_V3. Special
>>> thanks to David S. Miller, and also Eric Leblond and Victor Julien!
>>>
>>> Cc: Eric Leblond <eric@regit.org>
>>> Cc: Victor Julien <victor@inliniac.net>
>>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>>> ---
>>>   Documentation/networking/packet_mmap.txt | 327
>>>   +++++++++++++++++++++++++++++++
>>>   1 file changed, 327 insertions(+)
>>
>> tools/testing/selftests/net  seems a better place to get another
>> program ?
> 
> Hm, well. Actually, it should serve as nothing more than a code
> example that does nothing useful except shows how to use it. Just
> like the packet fanout example in the same file. It should just
> provide a starting point for people to grab it and build something
> bigger out of it.

Agreed, and applied, thanks Daniel.
