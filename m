From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 2/6] bpf: add meta pointer for direct access
Date: Thu, 28 Sep 2017 14:22:43 -0700
Message-ID: <bdce98b7-1d32-3cd9-1289-79807af8443f@gmail.com>
References: <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net>
 <20170925181000.GA60144@C02RW35GFVH8.dhcp.broadcom.net>
 <59C94FF4.8070900@iogearbox.net>
 <20170926172140.GB60144@C02RW35GFVH8.dhcp.broadcom.net>
 <E0D909EE5BB15A4699798539EA149D7F077E53D6@ORSMSX103.amr.corp.intel.com>
 <CAHashqBMfXp-uYH9ANfdaNfez9f4pcrOjnbX2WAFAdBwaJAtvw@mail.gmail.com>
 <E0D909EE5BB15A4699798539EA149D7F077E6438@ORSMSX103.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        "jakub.kicinski@netronome.com" <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mchan@broadcom.com" <mchan@broadcom.com>
To: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:53365 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751129AbdI1VXC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 17:23:02 -0400
Received: by mail-pg0-f54.google.com with SMTP id j70so1607028pgc.10
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 14:23:02 -0700 (PDT)
In-Reply-To: <E0D909EE5BB15A4699798539EA149D7F077E6438@ORSMSX103.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

> I'm pretty sure I misunderstood what you were going after with 
> XDP_REDIRECT reserving the headroom.  Our use case (patches coming in a 
> few weeks) will populate the headroom coming out of the driver to XDP, 
> and then once the XDP program extracts whatever hints it wants via 
> helpers, I fully expect that area in the headroom to get stomped by 
> something else.  If we want to send any of that hint data up farther, 
> we'll already have it extracted via the helpers, and the eBPF program 
> can happily assign it to wherever in the outbound metadata area.

In case its not obvious with the latest xdp metadata patches the outbound
metadata can then be pushed into skb fields via a tc_cls program if needed.

.John

> 
>> (There's also Jesper's series from today -- I've seen it but have not
>> had time to fully grok all of those changes.)
> 
> I'm also working through my inbox to get to that series.  I have some 
> email to catch up on...
> 
> Thanks Andy,
> -PJ
> 
