From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next] net: filter: export pkt_type_offset() helper
Date: Thu, 11 Sep 2014 21:01:12 -0700
Message-ID: <CAADnVQKT7RC9T9fJBeaBHPHA_=ivEA3jR3QiQ7LQ=8791_C6NQ@mail.gmail.com>
References: <1409778511-21273-1-git-send-email-kda@linux-powerpc.org>
	<54078FBC.5050402@redhat.com>
	<CAADnVQKNHL7iY=VHp4bs5k2hSDf8jy7H-0H0SgYjb81S25XB9Q@mail.gmail.com>
	<1409792893.26422.60.camel@edumazet-glaptop2.roam.corp.google.com>
	<1409793959.3362714.163402573.6A26EDE1@webmail.messagingengine.com>
	<1409796348.26422.76.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAADnVQLh6qOD2epUq0S5P8RkUgZA38JNxeP40uBMScLHC2SsJg@mail.gmail.com>
	<CAHj3AVn8q-JS0Eq0QrfpBo-WfJ+-wXumhNoeDAdkPZC7LSeB5g@mail.gmail.com>
	<1409831412.23465.3.camel@localhost>
	<1409836154.26422.101.camel@edumazet-glaptop2.roam.corp.google.com>
	<1409838010.23465.16.camel@localhost>
	<1409839892.26422.115.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D174876B4@AcuExch.aculab.com>
	<1409841129.26422.117.camel@edumazet-glaptop2.roam.corp.google.com>
	<1409841233.23465.22.camel@localhost>
	<1409841347.26422.118.camel@edumazet-glaptop2.roam.corp.google.com>
	<1409841709.23465.25.camel@localhost>
	<CAADnVQL6s_DRE2aMEw=oBdcu6Bn0Q5CfZ_CKJ4xdGdcp5cRV7w@mail.gmail.com>
	<1409870759.2310959.163817265.10353D86@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	Denis Kirjanov <kirjanov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:40789 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbaILEBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 00:01:13 -0400
Received: by mail-qa0-f48.google.com with SMTP id v10so158262qac.21
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 21:01:12 -0700 (PDT)
In-Reply-To: <1409870759.2310959.163817265.10353D86@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 4, 2014 at 3:45 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>> >
>> > I think the latest proposals looks good?
>>
>> to me: yes
>> and I think your latest half-patch with:
>> +       __u8                    __pkt_type_offset[0];
>> also looks good.
>>
>> Are you going to take it over from Denis here?
>
> I don't know. Denis, do you want to incorperate my changes or should I
> take over here?

Hannes, Denis,
anyone of you going to continue on that?
imo it's a good cleanup.
