From: "Michael Gibson" <mgibson@esesixtech.com>
Subject: pcnet32 fiberoptic
Date: Tue, 23 Apr 2002 09:31:37 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <028601c1ea98$e75bb480$3201a8c0@thinstuff.com>
Reply-To: "Michael Gibson" <mgibson@esesixtech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: <linux-net@vger.kernel.org>
List-Id: netdev.vger.kernel.org

Hi All,

Maybe somebody can help us with this issue:

1. We have applied following patch to the pcnet32 driver for kernel 2.4.17
http://www.uwsg.iu.edu/hypermail/linux/net/0102.0/0019.html
to make the fiberoptic port work for Allied Telesyn AT-2450FTX NW card.
This card has 2 interfaces: a Fiberoptic 10Mbit (ST Inerface) and a TP
10/100Mbit interface
We are using it togeteher with the "MC13 Ethernet Media Converter" also from
allied telesyn.
This is a media converter from fiberoptic (10MBit) to 10MBit TP.
We connected it to a 10Mbit TP HUB.
We are using the 10Mbit Fiberoptic interface of this card and it is about 30
times slower then a normal 10Mbit TP Lan.
So IMHO that should be a driver problem and not normal.
But maybe I am wrong.

We are also using an Allied Telesyn AT-2700FX card.
This card has only one interface: a Fiberoptic 100Mbit (ST Inerface)
We are using this one together with the "MC101XL Fast Ethernet Media
Converter" also from Allied Telesyn.
This is a media converter from fiberoptic (100MBit) to 100MBit TP.
We connected it to a 100Mbit TP switch.
This card is about the same speed as a normal 100Mbit TP card.

Both above cards. The 10Mbit fiber and the 100Mbit fiber have exactely the
same AMD chip: PCnet Fast+, AM79C972BKC.


Does somebody have any idea what could be causing the problem that the
10Mbit fiber
card is so terribly slow?
Can this fiber patch be included into the pcnet32 driver?

Best regards
Michael Gibson



