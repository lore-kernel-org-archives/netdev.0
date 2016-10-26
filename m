From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] packet: on direct_xmit, limit tso and csum to
 supported devices
Date: Wed, 26 Oct 2016 00:29:25 -0400
Message-ID: <CAF=yD-KbxKZeC2e6CnrMPTgjkF1TuDGHJ3FjJcMESLspY_HJ2w@mail.gmail.com>
References: <1477441683-68242-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <1477443451.7065.163.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:33323 "EHLO
        mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751036AbcJZEaG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 00:30:06 -0400
Received: by mail-vk0-f68.google.com with SMTP id h7so1278408vkf.0
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 21:30:06 -0700 (PDT)
In-Reply-To: <1477443451.7065.163.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 25, 2016 at 8:57 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-10-25 at 20:28 -0400, Willem de Bruijn wrote:
>> From: Willem de Bruijn <willemb@google.com>
>>
>> When transmitting on a packet socket with PACKET_VNET_HDR and
>> PACKET_QDISC_BYPASS, validate device support for features requested
>> in vnet_hdr.
>
>
> You probably need to add an EXPORT_SYMBOL(validate_xmit_skb_list)
> because af_packet might be modular.

Thanks, Eric. I'll send a v2.
