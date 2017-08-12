From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [PATCH 1/2] mpls: add handlers
Date: Sat, 12 Aug 2017 15:35:39 +0200
Message-ID: <c6fc221b-c0fa-1dbc-d1e2-a746b722dcd7@6wind.com>
References: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
 <1502396917-14848-2-git-send-email-amine.kherbouche@6wind.com>
 <20170811123405.GY773745@eidolon>
 <CAJieiUiDN0pk2GDb2+jBQzbjdPTpckSm23SCFGZ9mRHWfQ1H4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:34340 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750864AbdHLNfm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2017 09:35:42 -0400
Received: by mail-wr0-f173.google.com with SMTP id g28so2600742wrg.1
        for <netdev@vger.kernel.org>; Sat, 12 Aug 2017 06:35:41 -0700 (PDT)
In-Reply-To: <CAJieiUiDN0pk2GDb2+jBQzbjdPTpckSm23SCFGZ9mRHWfQ1H4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/08/2017 16:37, Roopa Prabhu wrote:
> On Fri, Aug 11, 2017 at 5:34 AM, David Lamparter <equinox@diac24.net> wrote:
>> On Thu, Aug 10, 2017 at 10:28:36PM +0200, Amine Kherbouche wrote:
>>> Mpls handler allows creation/deletion of mpls routes without using
>>> rtnetlink. When an incoming mpls packet matches this route, the saved
>>> function handler is called.
>> Since I originally authored this patch, I have come to believe that it
>> might be unneccessarily complicated.  It is unlikely that a lot of
>> different "handlers" will exist here;  the only things I can think of
>> are VPLS support and BIER-MPLS multicast replication.  I'm not saying
>> it's a bad idea, but, well, this was in the README that I gave to 6WIND
>> with this code:
>>
>> ...
> yes, I would also prefer just exporting the functions  and calling
> them directly instead of adding a
> handler layer. We can move to that later if it becomes necessary.
I understand that the handler layer is an overhead (as said by David's
note), and I agree with the solution for exporting the mpls functions that
allows route creation/deletion, but how about forwarding the right mpls
packet to the right vpls device with the device ptr? I don't see
another way.
