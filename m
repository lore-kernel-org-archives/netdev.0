From: Mason <slash.tmp@free.fr>
Subject: Re: [RFC PATCH v2 0/2] nb8800 suspend/resume support
Date: Wed, 2 Aug 2017 18:07:52 +0200
Message-ID: <6906dccf-bec9-0fc8-a34a-c39c05ada917@free.fr>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
 <aa8885b8-e6bb-3624-2bf9-0bb40505ac54@free.fr>
 <dd883398-1511-0bfd-972b-a11ef8709f0d@free.fr> <yw1xshhagexd.fsf@mansr.com>
 <9e8e12b1-74e2-8323-ec16-eebda46b2a3d@free.fr> <yw1xo9rygdyu.fsf@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:61435 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751763AbdHBQIG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 12:08:06 -0400
In-Reply-To: <yw1xo9rygdyu.fsf@mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2017 17:56, Måns Rullgård wrote:

> Mason writes:
> 
>> From my perspective, the older method does not work on newer chips :-)
> 
> It does work on tango4.

Agreed.

> What does the tango5 do if you flood it with packets faster than the
> kernel can keep up with?  That would make it hit the end of the rx
> chain, which is apparently what makes it miserable with the current dma
> stop code.

The simplest way to test this would be sending tiny packets
as fast as possible, right? So ping -f on a GigE link should
fit the bill?

Regards.
