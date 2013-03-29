From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] doc: packet: add minimal TPACKET_V3 example
 code
Date: Fri, 29 Mar 2013 16:50:02 +0100
Message-ID: <5155B82A.2050701@redhat.com>
References: <1364571389-26326-1-git-send-email-dborkman@redhat.com> <1364571737.5113.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eric Leblond <eric@regit.org>,
	Victor Julien <victor@inliniac.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755064Ab3C2PuY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Mar 2013 11:50:24 -0400
In-Reply-To: <1364571737.5113.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2013 04:42 PM, Eric Dumazet wrote:
> On Fri, 2013-03-29 at 16:36 +0100, Daniel Borkmann wrote:
>> Lost in space for a long time, but it finally came back to us from
>> some ancient code tombs. This patch adds a minimal runnable example
>> of Linux' packet mmap(2) from Chetan Loke's TPACKET_V3. Special
>> thanks to David S. Miller, and also Eric Leblond and Victor Julien!
>>
>> Cc: Eric Leblond <eric@regit.org>
>> Cc: Victor Julien <victor@inliniac.net>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   Documentation/networking/packet_mmap.txt | 327 +++++++++++++++++++++++++++++++
>>   1 file changed, 327 insertions(+)
>
> tools/testing/selftests/net  seems a better place to get another
> program ?

Hm, well. Actually, it should serve as nothing more than a code example
that does nothing useful except shows how to use it. Just like the packet
fanout example in the same file. It should just provide a starting point
for people to grab it and build something bigger out of it.

In a follow-up patch I could add a test case, /specificly designed/ to
do basic sanity checks. I think if people are looking for that, they
might not be starting under tools/testing/selftests/net, no?
