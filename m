From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system (2.6.33.3)
Date: Tue, 18 May 2010 16:55:17 +0200
Message-ID: <4BF2AA55.5050100@ans.pl>
References: <C27F8246C663564A84BB7AB3439772421B7814753A@IRVEXCHCCR01.corp.ad.broadcom.com>	 <1274040928.2299.17.camel@edumazet-laptop>  <4BF056F0.8010008@ans.pl>	 <1274042826.2299.26.camel@edumazet-laptop>  <4BF05FC2.4020804@ans.pl>	 <1274045180.2299.38.camel@edumazet-laptop>  <4BF2A288.7040304@ans.pl> <1274192761.8274.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:57461 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757872Ab0EROzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 10:55:23 -0400
In-Reply-To: <1274192761.8274.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-05-18 16:26, Eric Dumazet wrote:
> Le mardi 18 mai 2010 =C3=A0 16:22 +0200, Krzysztof Ol=C4=99dzki a =C3=
=A9crit :
>
>> Thank you. What happens if I set it to a lower/bigger value, than
>> avaliable txqueues in a NIC?
>
> lower values ->  same situation than today (not all txqueues will be
> used)
>
> bigger values ->  it will be capped, so its only a bit more ram
> allocated.

So it is safe to put there little bigger value than needed. Thanks.

Best regards,

			Krzysztof Ol=C4=99dzki
