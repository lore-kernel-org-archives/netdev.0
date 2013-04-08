From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: v3.8.5: "TCP: snd_cwnd is nul, please report this bug."
Date: Mon, 08 Apr 2013 11:06:48 +0200
Message-ID: <87zjx9pf13.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44737 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752895Ab3DHJGw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 05:06:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I just got this message running a Debian experimental
linux-image-3.8-trunk-amd64 kernel, currently based on v3.8.5.

Peeked briefly through the commit adding the message, but I couldn't
figure out what other info you'd need so please ask if there is anythin=
g
I can dig up.

I suspect the warning could be related to problems with the iwlwifi
driver and/or access point.  The message was immediately followed  by a
few messges from iwlwifi:


Apr  8 10:58:09 nemi kernel: [152701.980799] TCP: snd_cwnd is nul, plea=
se report this bug.
Apr  8 10:58:33 nemi kernel: [152725.176151] iwlwifi 0000:03:00.0: fail=
 to flush all tx fifo queues
Apr  8 10:58:33 nemi kernel: [152725.185713] wlan0: authenticate with 0=
0:22:90:f9:23:a0
Apr  8 10:58:33 nemi kernel: [152725.185738] wlan0: capabilities/regula=
tory prevented using AP HT/VHT configuration, downgraded
Apr  8 10:58:33 nemi kernel: [152725.190150] wlan0: send auth to 00:22:=
90:f9:23:a0 (try 1/3)
Apr  8 10:58:33 nemi kernel: [152725.199812] wlan0: authenticated
Apr  8 10:58:33 nemi kernel: [152725.200020] iwlwifi 0000:03:00.0 wlan0=
: disabling HT as WMM/QoS is not supported by the AP
Apr  8 10:58:33 nemi kernel: [152725.200027] iwlwifi 0000:03:00.0 wlan0=
: disabling VHT as WMM/QoS is not supported by the AP
Apr  8 10:58:33 nemi kernel: [152725.204033] wlan0: associate with 00:2=
2:90:f9:23:a0 (try 1/3)
Apr  8 10:58:33 nemi kernel: [152725.207317] wlan0: RX AssocResp from 0=
0:22:90:f9:23:a0 (capab=3D0x421 status=3D0 aid=3D12)
Apr  8 10:58:33 nemi kernel: [152725.210745] wlan0: associated



Bj=C3=B8rn
