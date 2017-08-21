From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [PATCH 3/6] mpls: add VPLS entry points
Date: Mon, 21 Aug 2017 18:13:42 +0200
Message-ID: <ba943611-d73e-a73c-1f0d-e4ad2d164741@6wind.com>
References: <20170816170202.456851-1-equinox@diac24.net>
 <20170816170202.456851-4-equinox@diac24.net>
 <268e2bb8-b35b-61ed-1e23-59200f67c621@6wind.com>
 <20170821155525.GW773745@eidolon>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:37248 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754222AbdHUQNw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 12:13:52 -0400
Received: by mail-wr0-f170.google.com with SMTP id z91so101821888wrc.4
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 09:13:51 -0700 (PDT)
In-Reply-To: <20170821155525.GW773745@eidolon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/21/2017 05:55 PM, David Lamparter wrote:
>>> +	if (rt->rt_payload_type == MPT_VPLS)
>>> > > +		return vpls_rcv(skb, dev, pt, rt, hdr, orig_dev);
>> >
>> > you should get the ret value of vpls_rcv() and increment stats if error
>> > occurs.
> An error in vpls_rcv() is not a receive error on the outer device's MPLS
> layer;  the packet was received correctly (and counted for that at the
> beginning of mpls_forward()) and dispatched onto an appropriately
> configured VPLS device.  vpls_rcv() counts its own stats on the inner
> device.

Right.
