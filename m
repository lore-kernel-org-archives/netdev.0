From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: net/can: use-after-free in bcm_rx_thr_flush
Date: Wed, 23 Nov 2016 07:06:03 +0100
Message-ID: <8ee2daed-fcf6-20c0-ef22-3ccb1b67d306@hartkopp.net>
References: <CAAeHK+xhwpVO=xHqEOyP-Tm6cx1+jDLDpYT0hpMwM2PCf7W3Jw@mail.gmail.com>
 <5abd6ebd-1249-71a9-da30-65d8371a2a36@hartkopp.net>
 <CAAeHK+x+SwBFj3iRfNN0S-5=kPXLdTgGZaoBAT+L0QpdU+0-vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        syzkaller <syzkaller@googlegroups.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.219]:23080 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750945AbcKWGGU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 01:06:20 -0500
In-Reply-To: <CAAeHK+x+SwBFj3iRfNN0S-5=kPXLdTgGZaoBAT+L0QpdU+0-vw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2016 06:37 PM, Andrey Konovalov wrote:
> On Tue, Nov 22, 2016 at 6:29 PM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
>> Hi Andrey,
>>
>> thanks for the report.
>>
>> Although I can't see the issue in the code ...
>>

Oh, I can see it now m(

Will send a patch today.

Many thanks,
Oliver
