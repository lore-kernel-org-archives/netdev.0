From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Subject: Re: [PATCH] wimax/i2400m: Remove VLAIS
Date: Wed, 25 Oct 2017 21:06:44 +0000
Message-ID: <0D40C184-7F45-408C-8411-C09E655BA1A0@intel.com>
References: <20171009194153.30467-1-mka@chromium.org>
         ,<20171024194659.GC96615@google.com>
         <3A78FAA0EC814D4B8ECC99B3AB32B332843B9D96@fmsmsx104.amr.corp.intel.com>
        ,<1508947039.19417.0.camel@redhat.com>
         <3A78FAA0EC814D4B8ECC99B3AB32B332843BB118@fmsmsx104.amr.corp.intel.com>,<1508953140.23414.1.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Matthias Kaehlcke <mka@chromium.org>,
        linux-wimax <linux-wimax@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Behan Webster <behanw@converseincode.com>,
        Mark Charlebois <charlebm@gmail.com>,
        "Arnd Bergmann" <arnd@arndb.de>,
        Guenter Roeck <groeck@chromium.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:48937 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751668AbdJYVGq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 17:06:46 -0400
In-Reply-To: <1508953140.23414.1.camel@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On Oct 25, 2017, at 10:39, Dan Williams <dcbw@redhat.com> wrote:
> 
> On Wed, 2017-10-25 at 17:12 +0000, Perez-Gonzalez, Inaky wrote:
>>> On Tue, 2017-10-24 at 21:00 +0000, Perez-Gonzalez, Inaky wrote:
>>>>> ping any comments on this?
>>>> 
>>>> None from me; I don't have access to this HW anymore, so I can't
>>>> validate if the change would work or not.
>>> I still have a 5350 around somewhere, I can make sure firmware
>>> loads if
>>> you like.
>> 
>> That'd be swell Dan, thx
> 
> Seems to load firmware, read the MAC, and reboot the card.  Couldn't
> get userspace tools working in a 5m try but the kernel module debug
> traces indicate the card TX/RX-es commands and we can pull out the card
> state and rfkill status and things like that.
> 
> Inaky, is that enough to verify the patch is OK?

It is, thanks Dan

Acked-by: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
