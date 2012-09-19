From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCHv2 bridge 5/7] bridge: Add vlan support to static neighbors
Date: Wed, 19 Sep 2012 11:24:02 -0400
Message-ID: <5059E392.3050207@redhat.com>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com> <1348058536-22607-6-git-send-email-vyasevic@redhat.com> <5059E2BB.8060507@intel.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754200Ab2ISPYF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 11:24:05 -0400
In-Reply-To: <5059E2BB.8060507@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2012 11:20 AM, John Fastabend wrote:
> On 9/19/2012 5:42 AM, Vlad Yasevich wrote:
>> ---
>>   include/linux/neighbour.h |    2 +-
>>   net/bridge/br_fdb.c       |   12 ++++++------
>>   2 files changed, 7 insertions(+), 7 deletions(-)
>>
>> diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
>> index 275e5d6..044df8f 100644
>> --- a/include/linux/neighbour.h
>> +++ b/include/linux/neighbour.h
>> @@ -7,7 +7,7 @@
>>   struct ndmsg {
>>       __u8        ndm_family;
>>       __u8        ndm_pad1;
>> -    __u16        ndm_pad2;
>> +    __u16        ndm_vlan;
>
> But ndm_pad2 is also used in neighbour.c so you'll need to fix that u=
p
> as well.
>
> net/core/neighbour.c: In function =E2neigh_fill_info=E2:
> net/core/neighbour.c:2152: error: =E2struct ndmsg=E2 has no member na=
med
> =E2ndm_pad2=E2
> net/core/neighbour.c: In function =E2pneigh_fill_info=E2:
> net/core/neighbour.c:2203: error: =E2struct ndmsg=E2 has no member na=
med
> =E2ndm_pad2=E2
> make[2]: *** [net/core/neighbour.o] Error 1
> make[1]: *** [net/core] Error 2
> make[1]: *** Waiting for unfinished jobs....
> make: *** [net] Error 2
> make: *** Waiting for unfinished jobs....


dough!!!  patches from wrong branch.  sorry about that.

-vlad
