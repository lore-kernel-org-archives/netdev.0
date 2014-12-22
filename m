From: Andre Tomt <andre@tomt.net>
Subject: Re: REGRESSION in nfnetlink on 3.18.x (bisected)
Date: Tue, 23 Dec 2014 00:23:11 +0100
Message-ID: <5498A7DF.6040903@tomt.net>
References: <5496075F.3060204@tomt.net> <20141222115607.GA4961@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20141222115607.GA4961@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22. des. 2014 12:56, Pablo Neira Ayuso wrote:
> On Sun, Dec 21, 2014 at 12:33:51AM +0100, Andre Tomt wrote:
>> On at least Ubuntu 14.04 LTS and Ubuntu 14.10 "conntrack -E" has
>> started failing with Linux 3.18.x. conntrack -L still works.
>>
>> 14.04 and 14.10 ships conntrack-utils version 1.4.1, but 1.4.2 does
>> not work either.
>>
>> It fails with:
>>> # conntrack -E
>>> conntrack v1.4.2 (conntrack-tools): Can't open handler
>>
>> strace shows:
>>> bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
>>> getsockname(3, {sa_family=AF_NETLINK, pid=14092, groups=00000000}, [12]) = 0
>>> bind(3, {sa_family=AF_NETLINK, pid=14092, groups=00000007}, 12) = -1 EINVAL (Invalid argument)
>>
>> Reverting 97840cb67ff5ac8add836684f011fd838518d698 - netfilter:
>> nfnetlink: fix insufficient validation in nfnetlink_bind
>
> Could you give a test to this patch? Thanks.
>

Initial testing looks good with this patch applied on top of 3.18.1
I will give it a spin on some more systems tomorrow.

Thanks
