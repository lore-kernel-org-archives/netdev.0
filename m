From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCHv2 net-next 0/4] Small fix for TCP PMTU
Date: Fri, 27 Feb 2015 13:37:44 +0800
Message-ID: <54F002A8.307@gmail.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com> <1424922566-6787-1-git-send-email-fan.du@intel.com> <063D6719AE5E284EB5DD2968C1650D6D1CAEEABA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'Fan Du' <fan.du@intel.com>,
	"johnwheffner@gmail.com" <johnwheffner@gmail.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:39366 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034AbbB0Fmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 00:42:36 -0500
Received: by pdjy10 with SMTP id y10so18582342pdj.6
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 21:42:36 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAEEABA@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B402=E6=9C=8826=E6=97=A5 21:40, David Laight =E5=86=
=99=E9=81=93:
> From: Fan Du
>> >This patchset performs some small fix and enhancement
>> >for current TCP PMTU as per RFC4821 with below changes:
>> >
>> >Patch1/4: Set probe mss base to 1024 Bytes per RFC4821
>> >Patch2/4: Do not double probe_size for each probing,
>> >           use a simple binary search to gain maximum performance.
>> >Patch3/4: When it comes to blackhole detection, shrink current
>> >	  mss for next probing.
>> >Patch4/4: Create a probe timer to detect enlarged path MTU.
> Isn't the most likely problem PPPoE blackholes?
No.

It's used to probe a optimal pmtu value for vxlan tunnel when ICMP mess=
age
is not available. Refer patch2/4 for test summary.

> Where a reduction of the PMTU from 1500 to (IIRC) 1492 is
> all that is required?
>
> Would seem appropriate to test that value reasonable quickly.
