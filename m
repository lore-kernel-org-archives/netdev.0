From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.	Now=15
 size=11 bits
Date: Thu, 02 Jul 2009 07:43:25 +0200
Message-ID: <4A4C48FD.7040002@itcare.pl>
References: <20090630070929.GB5589@ff.dom.local> <4A4A72B9.3030400@itcare.pl> <20090630204141.GB3026@ami.dom.local> <4A4AA03D.5090808@itcare.pl> <20090701063651.GA4876@ff.dom.local> <20090701072409.GA12592@ff.dom.local> <4A4B2FA8.3040007@itcare.pl> <20090701101333.GB12715@ff.dom.local> <20090701110407.GC12715@ff.dom.local> <4A4BE06F.3090608@itcare.pl> <20090702053216.GA4954@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:36121 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbZGBFnY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2009 01:43:24 -0400
In-Reply-To: <20090702053216.GA4954@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski pisze:
> On Thu, Jul 02, 2009 at 12:17:19AM +0200, Pawe=B3 Staszewski wrote:
>  =20
>> Jarek Poplawski pisze:
>>    =20
> ...
>  =20
>>> So, after your findings I'm about to recommend sending to -stable
>>> 3 patches from net-2.6, with additional lowering of threshold_root
>>> settings, but it would be nice if you could give it a try with
>>> CONFIG_PREEMPT instead of CONFIG_PREEMPT_NONE (if it doesn't break
>>> your other apps!) It is expected to work this time...;-) Maybe a
>>> bit slower.
>>>
>>>  =20
>>>      =20
>> Patch applied to 2.6.29.5 with CONFIG_PREEMPT_NONE
>> And working :)
>>    =20
>
> Hmm... It should, because you tested very similar patch already;-)
> Sorry if I didn't make it clear.
>
>  =20
Yes i know there was almost identical one.
And i see this was without sync rcu :)

>> fib_triestats in attached file
>>
>> I think I can test it with PREEMPT enabled but first i must make som=
e =20
>> other tests of my apps that are on server.
>>    =20
>
> It could probably matter only if you're using some broken out-of-tree
> patches. Otherwise the kernel is expected to work OK.
>
>  =20
Im a little confused about using of PREEMPT kernel because of past
there was many oopses / lockups :) but yes that was a little long time =
ago.
I will try to make this test today.

> Btw., it would be also interesting to check if there is any differenc=
e
> wrt. these route cache problems while PREEMPT is enabled.
>
> Thanks,
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>  =20

