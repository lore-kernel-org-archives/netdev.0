From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 3/3] bridge: request vlans along with link
 information
Date: Sun, 10 Sep 2017 13:24:53 +0300
Message-ID: <f167dbc9-baf2-89a6-33a3-982fac2fabd4@cumulusnetworks.com>
References: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
 <1504907543-14394-4-git-send-email-mrv@mojatatu.com>
 <CAJieiUhT75fM3LuhNW32QkbJA9TO5dHwb_G-aRD2H70jF-FG2A@mail.gmail.com>
 <5706e1ba-6b85-4f32-a858-b5d87b17eb51@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:46121 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750709AbdIJKY5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 06:24:57 -0400
Received: by mail-wm0-f41.google.com with SMTP id i189so23287168wmf.1
        for <netdev@vger.kernel.org>; Sun, 10 Sep 2017 03:24:56 -0700 (PDT)
In-Reply-To: <5706e1ba-6b85-4f32-a858-b5d87b17eb51@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/17 20:23, Jamal Hadi Salim wrote:
> On 17-09-09 12:24 PM, Roopa Prabhu wrote:
>> On Fri, Sep 8, 2017 at 2:52 PM, Roman Mashak <mrv@mojatatu.com> wrote:
[snip]
> 
> Agree we should be turning on this stuff by default. i.e default stays
> compressed; otherwise it a huge dump.
> 
> Having said that there is a lot of mess with this stuff.
> The bridge link events _already send this IFLA_AF_SPCE info_
> so not much choice  there but to print it.
> At minimal we need that part because unfortunately there is no
> vlanfilter event in existence which will send us summaries of just
> vlans added to a port i.e both use XXXLINK.
> In general, the XXXLINK interface with these master devices (bridge,
> bond etc) continues to get messy. Recently started seeing events with
> devices claiming to be of KIND_slave etc on the bridge and bond devices;
> yet at the same time my wireless card events are also showing up on the
> bridge link even though it is not enslaved there..

Out of curiousity about this one, do you see the wifi card when doing bridge monitor ?
Or are you specifically watching AF_BRIDGE events, because bridge monitor link also can
include AF_UNSPEC ?

> 
> cheers,
> jamal
> 
