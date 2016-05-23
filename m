From: Mathias Kresin <openwrt@kresin.me>
Subject: Re: [PATCH 1/1 RFC] net/phy: Add Lantiq PHY driver
Date: Mon, 23 May 2016 12:07:31 +0200
Message-ID: <CABwW5n=M3HNxT=5556fRfx4_yup3FwbaLBY5AkDOoa0EPSyK_A@mail.gmail.com>
References: <1463587403-26809-1-git-send-email-alexander.stein@systec-electronic.com>
	<6103030.g2sqFmaRhG@ws-stein>
	<9231D502B07C5E4A8B32D5115C9F19991E917469@IRSMSX101.ger.corp.intel.com>
	<8983627.qbi7VGpM7G@ws-stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Mehrtens, Hauke" <hauke.mehrtens@intel.com>,
	John Crispin <john@phrozen.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Alexander Stein <alexander.stein@systec-electronic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35107 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbcEWKHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 06:07:33 -0400
Received: by mail-io0-f173.google.com with SMTP id p64so98951931ioi.2
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 03:07:32 -0700 (PDT)
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com. [209.85.223.182])
        by smtp.gmail.com with ESMTPSA id l123sm3146022ita.1.2016.05.23.03.07.31
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 03:07:31 -0700 (PDT)
Received: by mail-io0-f182.google.com with SMTP id 190so190382615iow.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 03:07:31 -0700 (PDT)
In-Reply-To: <8983627.qbi7VGpM7G@ws-stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-05-23 11:49 GMT+02:00 Alexander Stein
<alexander.stein@systec-electronic.com>:

>> The registers are set to some reset values after the chip is coming out of
>> reset, but we should set  them all to the same value, Mathias said that all
>> except for one board he knows are using only one LED per port, but they are
>> often using different LED pins, I will change my patch.
>
> One LED per port? I would think of using one RJ45 socket per port which
> usually have 2 LEDs.

The majority of the CPEs I'm talking about, do not have any leds at
the back side RJ45 socket. They are using a single led at the front
for status indication.

I'm only aware of one CPE that has two LEDs at the RJ45 socket.

Mathias
