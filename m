From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 4.7 FIX] brcmfmac: fix lockup when removing P2P interface after event timeout
Date: Thu, 02 Jun 2016 12:42:55 +0300
Message-ID: <87eg8glye8.fsf@purkki.adurom.net>
References: <1464378815-23282-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brett Rudley <brudley@broadcom.com>,
	"Franky \(Zhenhui\) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
	Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464378815-23282-1-git-send-email-zajec5@gmail.com>
 (=?utf-8?Q?=22Rafa=C5=82=09Mi=C5=82ecki=22's?= message of "Fri, 27 May 2016
 21:53:14 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> writes:

> Removing P2P interface is handled by sending a proper request to the
> firmware. On success firmware triggers an event and driver's handler
> removes a matching interface.
>
> However on event timeout we remove interface directly from the cfg802=
11
> callback. Current code doesn't handle this case correctly as it alway=
s
> assumes rtnl to be unlocked.
>
> Fix it by adding an extra rtnl_locked parameter to functions and call=
ing
> unregister_netdevice when needed.
>
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

Arend, are you ok to push this to 4.7?

--=20
Kalle Valo
