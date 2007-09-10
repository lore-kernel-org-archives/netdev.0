From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [IPv6] BUG: NULL pointer dereference in(?) ip6_flush_pending_frames
Date: Mon, 10 Sep 2007 10:18:14 +0200
Message-ID: <46E4FDC6.3060809@birkenwald.de>
References: <20070909222400.GC7591@obelix.birkenwald.de> <20070910.083847.40751994.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, miyazawa@linux-ipv6.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:48216 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755136AbXIJISO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 04:18:14 -0400
In-Reply-To: <20070910.083847.40751994.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E:

Hi,

>> BUG: unable to handle kernel NULL pointer dereference at virtual add=
ress
>> 0000008c
> :
>> EIP is at ip6_flush_pending_frames+0x97/0x121
>=20
> I think I've found a bug.
[...]
> Anyway, please try this.

=46TR, I tried 2.6.22.6 without the patch and it failed as well. The=20
patched kernel is running since yesterday evening (about 8h now) and=20
seems to be stable so far. Too early to tell for sure, but I guess we=20
have a fix.

Thanks Yoshifuji!

Regards,
Bernhard
