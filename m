From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH net-next (V2, RESENT)] ipv6: Queue fragments per interface
 for multicast/link-local addresses.
Date: Sun, 17 Mar 2013 09:50:25 +0900
Message-ID: <51451351.50508@linux-ipv6.org>
References: <511F1E03.9010205@linux-ipv6.org> <511FB776.8000901@linux-ipv6.org> <20130316074745.GC24041@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130316074745.GC24041@order.stressinduktion.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Frederic Sowa wrote:
> On Sun, Feb 17, 2013 at 01:44:38AM +0900, YOSHIFUJI Hideaki wrote:
>> We should queue fragments for the same link-local address on
>> different interfaces (e.g. fe80::1%eth0 and fe80::1%eth1) to the
>> different queue, because of nature of addressing architecture.
>>
>> Similarly, we should queue fragments for multicast on different
>> interface to the different queue.  This is okay because
>> application joins group on speicific interface, and multicast
>> traffic is expected only on that interface.
>>
>> CC: Ben Greear <greearb@candelatech.com>
>> CC: Vlad Yasevich <vyasevic@redhat.com>
>> CC: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> I just found this patch while cleaning up my tree. I don't know its state
> (netdev patchworks says RFC and netfilter patchworks still lists it as
> new). However, I also do think that the per interface matching would be
> the right thing to do for multicast|linklocal fragments. Perhaps this patch
> should be resend?

Will do.

> Yoshifuji, do you think we should also implement RFC 3168 5.3 ECN
> fragmentation protection in reassembly.c? I think it should be
> straightforward because it is already implemented for ipv4 and the
> relevant bits just need to be moved to inet_fragment.c and become a bit
> more generalized.

OK.

--yoshfuji

