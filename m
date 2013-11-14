From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: how to mix bridges and bonding inc. vlans correctly on Kernel >
 3.10
Date: Thu, 14 Nov 2013 13:29:28 +0100
Message-ID: <20131114122928.GV19702@redhat.com>
References: <52838590.5070806@profihost.ag>
 <20131113141244.GM19702@redhat.com>
 <52838AC8.8070005@profihost.ag>
 <52839540.6020908@gmail.com>
 <5283980D.7020508@profihost.ag>
 <20131113162136.GP19702@redhat.com>
 <5283B500.9040408@gmail.com>
 <5283DC91.1010402@profihost.ag>
 <52843EEA.3020905@redhat.com>
 <52848010.8030103@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: vyasevic@redhat.com, Vlad Yasevich <vyasevich@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20333 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718Ab3KNMbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 07:31:49 -0500
Content-Disposition: inline
In-Reply-To: <52848010.8030103@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 08:47:28AM +0100, Stefan Priebe - Profihost AG wrote:
>Hi,
>
>> eth2
>>      \
>>       -- bond1 -- vmbr1
>>      /     \
>> eth3        ----- bond1.3000 --- vmbr1v3000
>>                                      \ ---- tap114i1
>
>thos one works fine now.
>
>
>> eth2
>>      \
>>       -- bond1 -- vmbr1
>>      /              \
>> eth3                 \ vmbr1.3000
>>                            \ ---- tap114i1
>
>this one does not. Another note to this one. It also never worked on
>RHEL6 - it started working with about 2.6.39 and stopped with 3.9 or
>3.10. But it was the only one where gvrp on vlans had worked.

bridge device in this config is neither master nor slave, if I read it
correctly.

You might want to try my patch to see if it works (my previous email).

>
>Greets,
>Stefan
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
