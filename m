From: Felipe Dias <felipediassss@gmail.com>
Subject: Re: skb->timestamp == 0.000000 ?
Date: Tue, 22 Nov 2011 11:04:45 -0300
Message-ID: <CAJX4=r2XBGGzMFgeKC-TvZ-WQ9skwoBFA5na_XiLNqDn0U9V+Q@mail.gmail.com>
References: <CAJX4=r3wTn9v6-5oEpGdeKkFjKsRLZwc76tE9M4FiVJX4Lpisg@mail.gmail.com>
	<20111121211140.GB24753@d2.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f66.google.com ([209.85.214.66]:38718 "EHLO
	mail-bw0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189Ab1KVOEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 09:04:47 -0500
Received: by bkbzt12 with SMTP id zt12so90618bkb.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 06:04:46 -0800 (PST)
In-Reply-To: <20111121211140.GB24753@d2.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2011 at 6:11 PM, Benjamin Poirier
<benjamin.poirier@gmail.com> wrote:
> On 11/11/19 18:13, Felipe Dias wrote:
>> And time_skb.tv_sec and time_skb.tv_usec are equal to 0;
>>
>> I'm doing some wrong ?
>
> Timestamps have to be enabled
> have a look at:
> net_enable_timestamp()
>

who is responsible for enabling? Would not it be the driver?

Some packets (icmp) appear timestamp other packages do not appear.

I'm confused, in my mind, after the registration of the "protocol
handler" (with dev_add_pack) any skb should have the timestamp.

Sorry, but I'm confused.

Best regards,
Felipe.
