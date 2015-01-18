From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bridge code in net-next does not compile
Date: Sun, 18 Jan 2015 02:45:26 -0800
Message-ID: <DF3B96A8-5E4E-4EF4-8C42-8981B76F967B@holtmann.org>
References: <D49DF51C-D713-4D2C-9CB0-F7C21403F68A@holtmann.org> <20150118103938.GA1944@nanopsycho.orion>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:46528 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbbARKpd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 05:45:33 -0500
In-Reply-To: <20150118103938.GA1944@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

>> when compiling net-next, the bridge code fails to compile:
>>=20
>> CC      net/bridge/br.o
>> In file included from net/bridge/br.c:22:0:
>> include/net/switchdev.h:73:1: error: expected identifier or =E2=80=98=
(=E2=80=99 before =E2=80=98{=E2=80=99 token
>> {
>> ^
>> include/net/switchdev.h:71:90: warning: =E2=80=98call_netdev_switch_=
notifiers=E2=80=99 declared =E2=80=98static=E2=80=99 but never defined =
[-Wunused-function]
>> static inline int call_netdev_switch_notifiers(unsigned long val, st=
ruct net_device *dev,
>=20
> Hi, I already sent fix:
>=20
> http://patchwork.ozlabs.org/patch/430160/

good. I was just building the same fix for it. Except with an actual co=
mmit message showing the error.

Next time please compile test your patches with CONFIG_NET_SWITCHDEV=3D=
n. You were adding code that depends on a kernel config option. So that=
 should have been something obvious to actually compile test.

Dave, if you prefer a commit message with the error, then I can send my=
 patch.

Regards

Marcel
