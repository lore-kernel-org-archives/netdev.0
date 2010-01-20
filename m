From: marco gaddoni <marco.gaddoni@gmail.com>
Subject: Re: tg3 driver / BCM5722 dropping to 10Base-HD
Date: Wed, 20 Jan 2010 08:40:55 +0100
Message-ID: <3b2bc9d1001192340t29834477oc2943e3306700c63@mail.gmail.com>
References: <3b2bc9d1001180617m8c2e8ddm2bc99099758e53c3@mail.gmail.com>
	 <20100119230827.GA23501@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:19813 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767Ab0ATHk4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 02:40:56 -0500
Received: by fg-out-1718.google.com with SMTP id 16so773184fgg.1
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2010 23:40:55 -0800 (PST)
In-Reply-To: <20100119230827.GA23501@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2010 at 00:08, Matt Carlson <mcarlson@broadcom.com> wro=
te:
> On Mon, Jan 18, 2010 at 06:17:32AM -0800, marco gaddoni wrote:
>> Hello,
>>
>> i have a dell with a BCM5722 driven by the tg3 driver.
>>
>> this pc is connected to an unmanaged switch by micronet;
>> the connection is at 1000MBs.
>>
>> the system is normally stable;
>> sometimes the connection get dropped to 10Mbs/HD.
>>
>> i can get te connection back up to 1000Mbps
>> with an ethtool -t eth0.
>>
>> do you have any idea on what is the cause of this ?
>> is this the wrong adderess?
>>
>> please cc: me as i am not subscibed to netdev.
>>
>> thank you in advance,
>> =C2=A0marco,
>
> Can you post the driver messages from the syslog and the output of
> ethtool -i eth0?
>
>

hello,

here they are:

tg3.c:v3.99d (May 26, 2009)
tg3 0000:01:00.0: setting latency timer to 64
eth0: Tigon3 [partno(BCM95722) rev a200] (PCI Express) MAC address
00:26:b9:2e:79:b9
eth0: attached PHY is 5722/5756 (10/100/1000Base-T Ethernet) (WireSpeed=
[1])
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[1]
eth0: dma_rwctrl[76180000] dma_mask[64-bit]
tg3 0000:02:00.0: setting latency timer to 64
eth1: Tigon3 [partno(BCM95722) rev a200] (PCI Express) MAC address
00:26:b9:2e:79:ba
eth1: attached PHY is 5722/5756 (10/100/1000Base-T Ethernet) (WireSpeed=
[1])
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[1]
eth1: dma_rwctrl[76180000] dma_mask[64-bit]

=2E..

tg3: eth0: Link is up at 1000 Mbps, full duplex.
tg3: eth0: Flow control is on for TX and on for RX.


srvlinux:~ # ethtool -i eth0
driver: tg3
version: 3.99d
firmware-version: 5722-v3.08, ASFIPMI v6.02
bus-info: 0000:01:00.0


--=20
"Reality continues to ruin my life." - Calvin.
