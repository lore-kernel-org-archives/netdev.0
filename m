From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: IPsec workshop at netdev01?
Date: Mon, 12 Jan 2015 18:19:38 +0100
Message-ID: <54B4022A.9080103@6wind.com>
References: <20150106101936.GC31458@secunet.com> <20150106170026.GD11324@breakpoint.cc> <20150107103137.GB13046@secunet.com> <20150107125554.GF11324@breakpoint.cc>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:33658 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbbALRTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 12:19:41 -0500
Received: by mail-lb0-f180.google.com with SMTP id l4so18740820lbv.11
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 09:19:40 -0800 (PST)
In-Reply-To: <20150107125554.GF11324@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/01/2015 13:55, Florian Westphal a =E9crit :
> Steffen Klassert <steffen.klassert@secunet.com> wrote:
>> On Tue, Jan 06, 2015 at 06:00:26PM +0100, Florian Westphal wrote:
>>> Steffen Klassert <steffen.klassert@secunet.com> wrote:
>>>> - We still lack a 32/64 bit compatibiltiy layer for IPsec, this is=
sue
>>>>    comes up from time to time. Some solutions were proposed in the=
 past
>>>>    but all had problems. The current behaviour is broken if someon=
e tries
>>>>    to configure IPsec with 32 bit tools on a 64 bit machine. Can w=
e get
>>>>    this right somehow or is it better to just return an error in t=
his case?
>>>
>>> FWIW I think
>>> http://patchwork.ozlabs.org/patch/49465/
>>>
>>> came closest to achieving full CONFIG_COMPAT support; since netlink=
 is
>>> no longer async now I'm not sure we'd still need additonal 32-compa=
t syscalls
>>> to make compat work for all cases.
>>>
>>> So "its ugly as hell" is probably the only problem that is hard to =
avoid ;-)
>>
>> Yeah, and it will be no fun to maintain it...
>
> Not sure, you'd have to make sure that no new attributes introduce ne=
ed
> to add another compat hack.
>
> The best argument against supporting it is that this problem
> has existed for so long that there arguably isn't much demand
> (else, such patch would have been merged years ago).
In fact, there is regularly some proposals to fix this, but I think tha=
t
nobody has taken the time to make a patch that satisfies everybody.
There is certainly a number of "private" patch for this problem, hence =
it
can be good to have a consensus on this topic.


Regards,
Nicolas
