From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Mon, 29 Jun 2009 11:43:54 +0200
Message-ID: <4A488CDA.1000804@itcare.pl>
References: <19012.37515.146191.198843@robur.slu.se> <20090627192057.GA5041@ami.dom.local> <19015.20051.432572.460207@robur.slu.se> <20090628143511.GA20541@ami.dom.local> <4A478D02.10805@itcare.pl> <4A4790C3.508@itcare.pl> <20090628213602.GA4584@ami.dom.local> <4A48766B.8020206@itcare.pl> <4A487FB0.7010903@itcare.pl> <20090629092703.GB4712@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:45319 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758727AbZF2Jny (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 05:43:54 -0400
In-Reply-To: <20090629092703.GB4712@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski pisze:
> On Mon, Jun 29, 2009 at 10:47:44AM +0200, Pawe=B3 Staszewski wrote:
>  =20
>> But
>> With all this patches i have the same problem with CPU load
>> Every time when route cache entries are purged cpu load is increasin=
g =20
>> from 1% to 40 / 80% it depends
>>
>> I see that on 64bit machine when route cache entries are going down =
i =20
>> have almost 80% load on each cpu where ethernet card is binded by =20
>> smp_affinity
>> But on 32bit machine cpu load reported by mpstat is half that on 64b=
it =20
>> machine
>> here is example from 32bit machine ( mpstat + rtstat -k entries )
>>
>> Linux 2.6.29.5 (TM_02_C1)       06/29/09        _i686_  (2 CPU)
>>
>> 12:36:54     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %s=
teal =20
>> %guest   %idle        RT CACHE ENTRIES (from rtstat)
>> 12:36:57     all    0.00    0.00    0.00    0.00    1.51   15.08    =
0.00 =20
>>   0.00   83.42        83346
>>    =20
>
> I guess Eric is thinking about this. Btw., two little suggestions:
> it should be easier to track if these route cache reports stay in its
> starting thread ("weird problem"?), and if you could send these
> stats/logs as attachements or turn off line wrapping, please? ;-)
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
Sorry Jarek for combining problems :)
And yes i will apply next stats in attachements :)

