From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Diagnostic Monitoring Interface Monitoring (DOM) PATCH 0/5 for
	net-next-2.6
Date: Wed, 25 Nov 2009 01:19:51 -0800
Message-ID: <9929d2390911250119h3e67fb50u2e9d8d3825b0496d@mail.gmail.com>
References: <19211.4244.135603.458550@gargle.gargle.HOWL>
	 <9929d2390911250018o777405ddk257605e7d0b16d17@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Robert Olsson <robert@herjulf.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:46382 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758214AbZKYJTq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 04:19:46 -0500
Received: by pzk1 with SMTP id 1so5473839pzk.33
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2009 01:19:52 -0800 (PST)
In-Reply-To: <9929d2390911250018o777405ddk257605e7d0b16d17@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 25, 2009 at 00:18, Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
> On Mon, Nov 23, 2009 at 14:45, Robert Olsson <robert@herjulf.net> wro=
te:
>>
>> Here are basic support to bring Diagnostic Monitoring Interface Moni=
toring (DOM)
>> to Linux this is more or less mandatory when building optical networ=
ks.
>>
>> Optical modules as SFP, SFP+, XFP, GBIC etc holds transceiver and li=
nk diagnostic
>> data needed to monitor and troubleshoot optical links, Talks to netw=
orks cards
>> via the I2C-bus (DOM lives in memory page 0xA2).
>>
>> In essential:
>>
>> Usage example: ethtool -D eth5
>>
>> Ext-Calbr: Avr RX-Power: Alarm & Warn: RX_LOS: =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 Wavelength: 1310 nm
>> Alarms, warnings in beginning of line, Ie. AH =3D Alarm High, WL =3D=
=3D Warn Low etc
>> =C2=A0 =C2=A0 =C2=A0 Temp: =C2=A035.9 C =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Thresh: Lo: -12.0/-8.0 =C2=A0 Hi: 10=
3.0/110.0 C
>> =C2=A0 =C2=A0 =C2=A0 Vcc: =C2=A03.33 V =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Thresh: Lo: =C2=A0 3.0/3.0 =C2=A0=
 =C2=A0Hi: =C2=A0 3.7/4.0 =C2=A0 V
>> =C2=A0 =C2=A0 =C2=A0 Tx-Bias: =C2=A013.4 mA =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 Thresh: Lo: =C2=A0 2.0/4.0 =C2=A0 =C2=A0Hi: =C2=
=A070.0/84.0 =C2=A0mA
>> ALWL =C2=A0 TX-pwr: =C2=A0-5.9 dBm ( 0.26 mW) =C2=A0 =C2=A0Thresh: L=
o: =C2=A0-4.0/-2.0 =C2=A0 Hi: =C2=A0 7.0/8.2 =C2=A0 dBm
>> AHWH =C2=A0 RX-pwr: =C2=A0-5.0 dBm ( 0.31 mW) =C2=A0 =C2=A0Thresh: L=
o: -35.2/-28.0 =C2=A0Hi: =C2=A0-8.2/-6.0 =C2=A0dBm
>>
>> Read more in Documentation/networking/dom.txt
>>
>> It's tested with the igb driver, there is also a patch for the ixgbe=
 driver but I
>> haven't any SFP+ with DOM support yet.
>>
>>
>> There are room for improvements an clean-ups.
>>
>> Cheers
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0--ro
>>
>
> Robert, to help get more eyes on this I have added it to my tree for
> internal testing and review.
>

=46YI- This patch series is riddled with trailing whitespace, when I
imported that patches into my tree, I cleaned up all the whitespace
errors.  After some internal testing and review, I can re-post the
entire series which has been cleaned up.

--=20
Cheers,
Jeff
