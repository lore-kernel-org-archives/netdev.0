From: John Crispin <john@phrozen.org>
Subject: Re: Upcoming cross-tree build breakage on merge window
Date: Tue, 19 Feb 2013 21:45:15 +0100
Message-ID: <5123E45B.8060203@phrozen.org>
References: <CACna6ryD3SjLN-oauvVuRa+q7an8DaULj+Uj4bwFSzQf2WCvMw@mail.gmail.com> <CACna6rwYZWsGhb8ksko+XGvod=hVyVHu2QrCfEisTG=YAEfBRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ralf@linux-mips.org, "David S. Miller" <davem@davemloft.net>,
	linux-mips@linux-mips.org,
	Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:40468 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934157Ab3BSUuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2013 15:50:11 -0500
In-Reply-To: <CACna6rwYZWsGhb8ksko+XGvod=hVyVHu2QrCfEisTG=YAEfBRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/02/13 20:44, Rafa=C5=82 Mi=C5=82ecki wrote:
> 2013/1/23 Rafa=C5=82 Mi=C5=82ecki<zajec5@gmail.com>:
>> I've noticed possible build breakage when two trees get merged:
>> net-next and linux-john (MIPS).
>>
>> This is about two following commits:
>> http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next.git;a=3Dc=
ommit;h=3Ddd4544f05469aaaeee891d7dc54d66430344321e
>> http://git.linux-mips.org/?p=3Djohn/linux-john.git;a=3Dcommit;h=3Da0=
08ca117bc85a9d66c47cd5ab18a6c332411919
>>
>> The first one adds "bgmac" driver which uses asm/mach-bcm47xx/nvram.=
h
>> and nvram_getenv. The second one renames them.
>>
>> Can you handle this in some clever way during merge window, please?
>>
>> The fix is trivial:
>> 1) Use<bcm47xx_nvram.h>
>> 2) Use bcm47xx_nvram_getenv
>
> Just a reminder.
>


Hi,

Ralf told me he will pull the fix into his upstream-sfr.git today so=20
that the upcoming linux-next should not build break due to this patch

	John
