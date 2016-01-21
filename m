From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2] wl1251: add sysfs interface for bluetooth coexistence mode configuration
Date: Thu, 21 Jan 2016 15:48:14 +0200
Message-ID: <87d1svyrfl.fsf@kamboji.qca.qualcomm.com>
References: <1451130310-16666-1-git-send-email-pali.rohar@gmail.com>
	<5696D08F.9030906@broadcom.com> <20160114091654.GA15380@amd>
	<20160121085331.GO7192@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Machek <pavel@ucw.cz>, Arend van Spriel <arend@broadcom.com>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Gnedt <david.gnedt@davizone.at>
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55868 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965183AbcAUNsV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 08:48:21 -0500
In-Reply-To: <20160121085331.GO7192@pali> ("Pali =?utf-8?Q?Roh=C3=A1r=22's?=
 message of "Thu, 21
	Jan 2016 09:53:31 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:

> On Thursday 14 January 2016 10:16:54 Pavel Machek wrote:
>> On Wed 2016-01-13 23:32:47, Arend van Spriel wrote:
>> > On 12/26/2015 12:45 PM, Pali Roh=C3=A1r wrote:
>> > >Port the bt_coex_mode sysfs interface from wl1251 driver version =
included
>> > >in the Maemo Fremantle kernel to allow bt-coexistence mode config=
uration.
>> > >This enables userspace applications to set one of the modes
>> > >WL1251_BT_COEX_OFF, WL1251_BT_COEX_ENABLE and WL1251_BT_COEX_MONO=
AUDIO.
>> > >The default mode is WL1251_BT_COEX_OFF.
>> > >It should be noted that this driver always enabled bt-coexistence=
 before
>> > >and enabled bt-coexistence directly affects the receiving perform=
ance,
>> > >rendering it unusable in some low-signal situations. Especially m=
onitor
>> > >mode is affected very badly with bt-coexistence enabled.
>> >=20
>> > So what user-space process will be using this interface. Did you c=
onsider
>> > adding debugfs interface? In case of monitor mode you could consid=
er
>> > disabling bt-coex from within the driver itself.
>>=20
>> This aint no debugging feature.
>
> Right, bt-coex is not for debugging purpose, but for normal usage, wh=
en
> user want to use together bluetooth and wifi or just one of those.

I think most of other drivers have a debugfs interface for btcoex, I
guess mostly for testing purposes. But this really should be added to
cfg80211.

--=20
Kalle Valo
