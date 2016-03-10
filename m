From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 0/3] validate variable length ll headers
Date: Wed, 9 Mar 2016 23:22:59 -0500
Message-ID: <CAF=yD-+RirnCYnCcREHx0G-a6MWMSYhx4zwzKxKOUSGyHRQsdw@mail.gmail.com>
References: <1457578714-36125-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <20160309.221340.1476836223911285635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f194.google.com ([209.85.217.194]:35757 "EHLO
	mail-lb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935028AbcCJEXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 23:23:40 -0500
Received: by mail-lb0-f194.google.com with SMTP id h2so7114182lbs.2
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 20:23:39 -0800 (PST)
In-Reply-To: <20160309.221340.1476836223911285635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 9, 2016 at 10:13 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Date: Wed,  9 Mar 2016 21:58:31 -0500
>
>> Allow device-specific validation of link layer headers. Existing
>> checks drop all packets shorter than hard_header_len. For variable
>> length protocols, such packets can be valid.
>>
>> patch 1 adds header_ops.validate and dev_validate_header
>> patch 2 implements the protocol specific callback for AX25
>> patch 3 replaces ll_header_truncated with dev_validate_header
>
> Series applied and queued up for -stable, thanks!

Thanks, David. Please don't queue the earlier net patchset for stable.
I spotted an issue while converting to net-next, I'm afraid. I can send a
net v2 (as net-next won't apply), or a separate stable patch once 4.5 is cut.
