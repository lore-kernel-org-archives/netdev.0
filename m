From: TJ Johnson <tjjohnson10200@gmail.com>
Subject: Fwd: Ethtool not displaying ntuple/nfc rule settings
Date: Tue, 29 May 2012 10:55:50 -0600
Message-ID: <CAFZv1415XPt+7v3xo6BR86cRKPju7QV7NQMAzS-O21TqvGBgBA@mail.gmail.com>
References: <CAFZv140-yrrDmD_H3ySEfJOL7Yp3syGt-VCNXaOi64nzucp5xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50427 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051Ab2E2Qzv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 12:55:51 -0400
Received: by yenm10 with SMTP id m10so2242802yen.19
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 09:55:51 -0700 (PDT)
In-Reply-To: <CAFZv140-yrrDmD_H3ySEfJOL7Yp3syGt-VCNXaOi64nzucp5xA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the double send. Had to convert to plain text as I received
failure messages.

---------- Forwarded message ----------
=46rom: TJ Johnson <tjjohnson10200@gmail.com>
Date: Tue, May 29, 2012 at 10:36 AM
Subject: Ethtool not displaying ntuple/nfc rule settings
To: netdev@vger.kernel.org, bhutchings@solarflare.com


Hi,

Not sure if this is even the right place to ask this, so feel free to p=
ush
me somewhere else if necessary. I am using ethtool's -U option to set u=
p
rules for an ixgbe device. That part seems to work great. However I am
unable to check the currently configured rules once they are in place.

ethtool -u DEVNAME produces this:
Cannot get RX rings: Operation not supported
rxclass: Cannot get RX class rule count: Operation not supported
RX classification rule retrieval failed

ethtool -n DEVNAME=A0rx-flow-hash=A0udp4 produces this:
Cannot get RX network flow hashing options: Operation not supported


The ethtool version I am using is 3.2, however I have tried 2.6.36-2.6.=
39.
Just used configure; make for building the tool.

ethtool -i gives this for the device version:

driver: ixgbe
version: 3.3.9-NAPI
firmware-version: 1.0-3
bus-info: 0000:0c:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no

The OS is SUSE Linux Enterprise Server 11 using a custom 2.6.36 kernel.

Any Ideas as to what the problem might be? Or how I can solve the issue=
?

Thanks,
TJ
