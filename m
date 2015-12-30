From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH v1 0/4] Add support emac for the RK3036 SoC
 platform
Date: Tue, 29 Dec 2015 20:48:47 -0500 (EST)
Message-ID: <20151229.204847.578920480799799256.davem@davemloft.net>
References: <1451287341-16453-1-git-send-email-zhengxing@rock-chips.com>
	<20151229.155314.1522114236952280828.davem@davemloft.net>
	<3925713.yDzK1dvrIv@diego>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zhengxing@rock-chips.com, linux-rockchip@lists.infradead.org,
	keescook@google.com, leozwang@google.comi, linux@arm.linux.org.uk,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	paul.gortmaker@windriver.com, galak@codeaurora.org,
	linux-kernel@vger.kernel.org, ijc+devicetree@hellion.org.uk,
	pawel.moll@arm.com, geert@linux-m68k.org, mark.rutland@arm.com,
	robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org
To: heiko@sntech.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753903AbbL3Bsw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 20:48:52 -0500
In-Reply-To: <3925713.yDzK1dvrIv@diego>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Heiko St=FCbner <heiko@sntech.de>
Date: Tue, 29 Dec 2015 23:27:55 +0100

> Hi Dave,
>=20
> Am Dienstag, 29. Dezember 2015, 15:53:14 schrieb David Miller:
>> You have to submit this series properly, the same problem happend tw=
ice
>> now.
>>=20
>> When you submit a series you should:
>>=20
>> 1) Make it clear which tree you expect these changes to be applied
>>    to.  Here it is completely ambiguous, do you want it to go into
>>    my networking tree or some other subsystem tree?
>>=20
>> 2) You MUST keep all parties informed about all patches for a series
>>    like this.  That means you cannot drop netdev from patch #4 as
>>    you did both times.  Doing this aggravates the situation for
>>    #1 even more, because if a patch is not CC:'d to netdev it does
>>    not enter patchwork.  And if it doesn't go into patchwork, I'm
>>    not looking at it.
>=20
> I guess that is some unfortunate result of git send-email combined wi=
th=20
> get_maintainer.pl . In general I also prefer to see the whole series,=
 but have=20
> gotten such partial series from other maintainers as well in the past=
, so it=20
> seems to be depending on preferences somewhat.
>=20
> For the series at hand, the 4th patch is the devicetree addition, whi=
ch the=20
> expected way is me picking it up, after you are comfortable with the =
code-
> related changes.

Why would it not be appropriate for a DT file change to go into my tree
if it corresponds to functionality created by the rest of the patches
in the series?

It looks better to put it all together as a unit, via one series, with
a merge commit containing your "[PATCH 0/N]" description in the commit
message.
