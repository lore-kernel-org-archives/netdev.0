From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Thu, 2 Jul 2009 05:32:16 +0000
Message-ID: <20090702053216.GA4954@ff.dom.local>
References: <20090630070929.GB5589@ff.dom.local> <4A4A72B9.3030400@itcare.pl> <20090630204141.GB3026@ami.dom.local> <4A4AA03D.5090808@itcare.pl> <20090701063651.GA4876@ff.dom.local> <20090701072409.GA12592@ff.dom.local> <4A4B2FA8.3040007@itcare.pl> <20090701101333.GB12715@ff.dom.local> <20090701110407.GC12715@ff.dom.local> <4A4BE06F.3090608@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:46267 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754723AbZGBFcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 01:32:19 -0400
Received: by fg-out-1718.google.com with SMTP id e12so1034091fga.17
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2009 22:32:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A4BE06F.3090608@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 02, 2009 at 12:17:19AM +0200, Pawe=B3 Staszewski wrote:
> Jarek Poplawski pisze:
=2E..
>> So, after your findings I'm about to recommend sending to -stable
>> 3 patches from net-2.6, with additional lowering of threshold_root
>> settings, but it would be nice if you could give it a try with
>> CONFIG_PREEMPT instead of CONFIG_PREEMPT_NONE (if it doesn't break
>> your other apps!) It is expected to work this time...;-) Maybe a
>> bit slower.
>>
>>  =20
> Patch applied to 2.6.29.5 with CONFIG_PREEMPT_NONE
> And working :)

Hmm... It should, because you tested very similar patch already;-)
Sorry if I didn't make it clear.

>
> fib_triestats in attached file
>
> I think I can test it with PREEMPT enabled but first i must make some=
 =20
> other tests of my apps that are on server.

It could probably matter only if you're using some broken out-of-tree
patches. Otherwise the kernel is expected to work OK.

Btw., it would be also interesting to check if there is any difference
wrt. these route cache problems while PREEMPT is enabled.

Thanks,
Jarek P.
