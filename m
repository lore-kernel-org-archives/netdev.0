From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [RFC PATCH v2 0/2] nb8800 suspend/resume support
Date: Thu, 03 Aug 2017 13:19:41 +0100
Message-ID: <yw1xy3r0g7xe.fsf@mansr.com>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
        <aa8885b8-e6bb-3624-2bf9-0bb40505ac54@free.fr>
        <dd883398-1511-0bfd-972b-a11ef8709f0d@free.fr>
        <yw1xshhagexd.fsf@mansr.com>
        <9e8e12b1-74e2-8323-ec16-eebda46b2a3d@free.fr>
        <yw1xo9rygdyu.fsf@mansr.com>
        <6906dccf-bec9-0fc8-a34a-c39c05ada917@free.fr>
        <yw1xk22mgdcx.fsf@mansr.com>
        <f1554ee7-2151-1304-c5c1-35264b9be5be@free.fr>
        <71dd7987-8c43-2548-5058-51a95658da71@free.fr>
        <c1aeaa45-de6a-e643-8765-7dad58a8b038@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:38442 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdHCMTm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 08:19:42 -0400
In-Reply-To: <c1aeaa45-de6a-e643-8765-7dad58a8b038@free.fr> (Mason's message
        of "Thu, 3 Aug 2017 10:34:31 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> IIUC, sender (desktop system) sends datagrams as fast as possible.
> Receiver (tango board) drops around 24% of all datagrams.
> I think this invalidates the theory that exhausting RX descriptors
> wedges RX DMA.

No, it doesn't.  The bottleneck causing packet loss could be somewhere
else.

-- 
Måns Rullgård
