From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [RFC 2/3] if_ether.h: Add IEEE 802.1 Local Experimental Ethertype 1.
Date: Mon, 5 Dec 2011 14:14:30 +0100
Message-ID: <CAJK669bK8kBXfc=j1q5NWEDCgSZwO0O=LsZ8z5GzB0S07gwBEQ@mail.gmail.com>
References: <1322685846-7790-1-git-send-email-sjur.brandeland@stericsson.com>
	<1322685846-7790-3-git-send-email-sjur.brandeland@stericsson.com>
	<5636a5efd90c56b538569ab019d7be4c@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Alexey Orishko <alexey.orishko@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?R=C3=A9mi_Denis=2DCourmont?= <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:47287 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756226Ab1LENOa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 08:14:30 -0500
Received: by qcqz2 with SMTP id z2so1413937qcq.19
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2011 05:14:30 -0800 (PST)
In-Reply-To: <5636a5efd90c56b538569ab019d7be4c@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi R=C3=A9mi,

>> Add EthType 0x88b5.
>> This Ethertype value is available for public use for prototype and
>> vendor-specific protocol development,as defined in Amendment 802a
>> to IEEE Std 802.
>
> I don't think you can just go and steal a reserved EtherType. What if=
 some
> user-space (using packet sockets) or out-of-tree kernel driver does a=
ctual
> "experiment" with this type?

I don't think defining this type in if_ether.h would harm anyone ;-)

I think your comments are applicable for the patch:
"caif: Add support for CAIF over CDC NCM USB interface".

Currently CAIF over CDC NCM USB is only deployed for the Ethernet link
between Host and Modem internally in a Smart Phone, and not out of the
Smart Phone (Tethering). The modem's Ethernet interface is connected to
the CAIF stack and not to the modem's IP stack.On the Linux Host,
CAIF takes this EthType into use *only* for a Ethernet interface with
the VID/PID of a ST-E CAIF modem.

With this setup I have a hard time seeing the big risk of interference =
with
others using this Ethernet Type.

We use Ethernet for this point-to-point link because  NCM 1.0 only
defines Ethernet as the only bearer. The long term solution for CAIF ov=
er
NCM should be based on MBIM 1.0 specification, where vendor specific
services can be define. We could then transmit CAIF frames directly
in a vendor specific service without the use of a Ethernet header.

> Why don't you define your own link-layer, e.g. with a vendor-specific=
 CDC
> profile?
I look into this...

BTW: Could you please do "reply-all" next time, so I get your mail in m=
y inbox.

Regards,
Sjur
