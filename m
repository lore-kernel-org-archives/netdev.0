From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: nfs broken in net-next? -- now in mainline -- bisected:
	d9f5950f90292f7cc42834338dfd5f44dc4cc4ca
Date: Sat, 12 Dec 2009 17:05:27 -0800
Message-ID: <86802c440912121705y59eea3ebq3bdbd3e7459e748e@mail.gmail.com>
References: <86802c440912112125v4aa72189ifcc2d16ecbf79cc4@mail.gmail.com>
	 <20091211.214117.200029438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mingo@elte.hu, sri@us.ibm.com, herbert@gondor.apana.org.au,
	torvalds@linux-foundation.org, sjayaraman@suse.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:60371 "HELO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750709AbZLMBLy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 20:11:54 -0500
In-Reply-To: <20091211.214117.200029438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 11, 2009 at 9:41 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Yinghai Lu <yhlu.kernel@gmail.com>
> Date: Fri, 11 Dec 2009 21:25:49 -0800
>
>> [linux-2.6]# git bisect good
>> d9f5950f90292f7cc42834338dfd5f44dc4cc4ca is first bad commit
>> commit d9f5950f90292f7cc42834338dfd5f44dc4cc4ca
>> Author: Sridhar Samudrala <sri@us.ibm.com>
>> Date: =A0 Wed Oct 7 12:24:25 2009 +0000
>>
>> =A0 =A0 net: Make UFO on master device independent of attached devic=
es
>
> Thanks.
>
> If I don't hear anything from Sridhar in a day or two I'll simply
> revert that change.

seems revert that doesn't fix the problem.

during bisecting, last several testing, i was using kexec instead of
boot from BIOS...

could be other commit like

[f86dcc5aa8c7908f2c287e7a211228df599e3e71] udp: dynamically
size hash tables at boot time

YH
