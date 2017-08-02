From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH v2 0/2] nb8800 suspend/resume support
Date: Wed, 2 Aug 2017 16:19:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD004937D@AcuExch.aculab.com>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
        <aa8885b8-e6bb-3624-2bf9-0bb40505ac54@free.fr>
        <dd883398-1511-0bfd-972b-a11ef8709f0d@free.fr>
        <yw1xshhagexd.fsf@mansr.com>
        <9e8e12b1-74e2-8323-ec16-eebda46b2a3d@free.fr>
        <yw1xo9rygdyu.fsf@mansr.com>
        <6906dccf-bec9-0fc8-a34a-c39c05ada917@free.fr>
 <yw1xk22mgdcx.fsf@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: =?Windows-1252?B?J03lbnMgUnVsbGflcmQn?= <mans@mansr.com>,
        Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:62047 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbdHBQT0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 12:19:26 -0400
In-Reply-To: <yw1xk22mgdcx.fsf@mansr.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Måns Rullgård
> Sent: 02 August 2017 17:10
...
> ping -f is limited to 100 packets per second.  Use something like iperf
> in UDP mode instead.

Or break a MAC driver so it just saturates the network.

You might actually need bursts of traffic - otherwise the receiver
will be continuously out of rx buffers and no dma will be active.

	David
