From: Oliver Graute <oliver.graute@gmail.com>
Subject: Re: Device Tree Binding for Marvell DSA Switch on imx28 board over
 Mdio Interface
Date: Wed, 19 Nov 2014 08:49:50 +0100
Message-ID: <CA+KjHfaHxkSY6py31ErXmerp=T68oGdz7D7pC+sXqRmkWEktcA@mail.gmail.com>
References: <CA+KjHfYZdZ88ZFzFCPN-bGphh+mnSWy6i0WNzFYv=gOsafXA7g@mail.gmail.com>
	<5463B2AC.6090904@gmail.com>
	<CA+KjHfbwtwPFXFEVDDijRNeTcHcSn0BZ4_yGuwcgyFfubNFCQA@mail.gmail.com>
	<54650E9C.7080708@gmail.com>
	<CA+KjHfZSeM=CPxbpoTAjbC3S5EKw+M59hii3t2zY4HePmFGZYg@mail.gmail.com>
	<CA+KjHfa=Tqs=CWe6TT+rbmc9UaFZghqW1OtigPm9wOyXgN2AOQ@mail.gmail.com>
	<CA+KjHfY13ynH4Zr5Cerhswo3eucj3DMwq0tZ5CQquT3yuxKv-Q@mail.gmail.com>
	<20141117160934.GR2001@lunn.ch>
	<CA+KjHfauqO=BxOogexO3azW27cb1gHqEL5Mh-c+qxfUMYvf_mw@mail.gmail.com>
	<546B8E92.7080000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew@lunn.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	buytenh@wantstofly.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:43663 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171AbaKSHtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 02:49:51 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so509417igb.11
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 23:49:50 -0800 (PST)
In-Reply-To: <546B8E92.7080000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 7:23 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 11/18/2014 12:30 AM, Oliver Graute wrote:
>>> Hi Oliver
>>>
>>> How do you have the strapping pins on the switch set? They determine
>>> what address on the mdio bus the chip responds to.
>>
>> On the circuit diagram the PIN 54  (P5_IND1/P5ID1) is set to
>> "Configuration Address: 0101"
>> P5_MODE[3:0]=0111 = Single RMII MAC Mode (100Mbps FD with 50 MHz clock input)
>> PIN 59 R1_LED/NO_CPU Configuration: CPU is attached SMI address is 0x10 to 0x1F
>>
>> But what is the mdio address of the whole switch? or can I only
>> address individual phy ports?
>
> You should specify in the Device Tree the switch pseudo-PHY address,
> typically 16 for Marvell switches. You can still access the individual
> ports' PHY addresses using address 0 through N.
>

How do I do that exactly? do you have an example Device Tree Snippet?


Best regards,

Oliver
