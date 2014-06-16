From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v2 0/5] Checksum fixes
Date: Mon, 16 Jun 2014 11:22:06 +0200
Message-ID: <CAMuHMdUg1yoffmBN=X_zUXQrrmf0UM5g6g8_je4JvWaqEpCQPQ@mail.gmail.com>
References: <alpine.DEB.2.02.1406142312290.17261@tomh.mtv.corp.google.com>
	<20140615.010113.950904601534084657.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	joseph.gasparakis@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38098 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaFPJWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 05:22:07 -0400
Received: by mail-wi0-f181.google.com with SMTP id n3so3658815wiv.8
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 02:22:06 -0700 (PDT)
In-Reply-To: <20140615.010113.950904601534084657.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom, David,

On Sun, Jun 15, 2014 at 10:01 AM, David Miller <davem@davemloft.net> wrote:
>> Fixes related to some recent checksum modifications.
>>
>> - Fix GSO constants to match NETIF flags
>> - Fix logic in saving checksum complete in __skb_checksum_complete
>> - Call __skb_checksum_complete from UDP if we are checksumming over
>>   whole packet in order to save checksum.
>> - Fixes to VXLAN to work correctly with checksum complete
>
> Series applied, thanks Tom.

I can confirm I see no more UDP checksum errors nor packet receive errors.

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
