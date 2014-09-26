From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 2/3] ipv6: mld: do not overwrite uri when receiving
 an mldv2 query
Date: Fri, 26 Sep 2014 14:23:48 +0200
Message-ID: <54255AD4.409@redhat.com>
References: <1411455828-5196-1-git-send-email-dborkman@redhat.com> <1411455828-5196-3-git-send-email-dborkman@redhat.com> <54243C89.6060405@oracle.com> <542475E3.6030508@redhat.com> <5424A408.5000208@oracle.com> <542531FA.2070701@redhat.com> <54255875.20409@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18150 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753803AbaIZMYF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 08:24:05 -0400
In-Reply-To: <54255875.20409@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2014 02:13 PM, David L Stevens wrote:
> On 09/26/2014 05:29 AM, Daniel Borkmann wrote:
>> On 09/26/2014 01:23 AM, David L Stevens wrote:
>
>> I'm fine with either suggestion. Actually the _current_ situation we're in is
>> that in IPv4 we _always_ use the current, uncached _sysctl_ tuned setting of URI
>> (independent of any protocol version); while in IPv6 we use the _cached_ sysctl
>> URI in case of MLDv1 and _always_ overwrite the URI in case of MLDv2 (even for
>> MLDv1). Are you suggesting that, we then better adapt using the maxdelay value
>> everywhere and adapt URI to it, plus having a boolean knob defaulting to off for
>> an admin to enforce always using the provided sysctl default setting and not
>> the snooped MLD?
>
> Yes.
>
> Definitely, IGMP and MLD, all versions, should do the same thing and I think that
> ought to use the querier MRC, if present and not overridden by an admin.
>
> Further, I think a version switch or failure to hear from a querier for qrv*qi
> ought to reset everything.

I'll recook the patch set and keep you in the loop. Thanks David!

Best,
Daniel
