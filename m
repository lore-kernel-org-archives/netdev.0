From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 3/3] net/tcp_fastopen: Remove mss check in tcp_write_timeout()
Date: Thu, 20 Apr 2017 23:06:50 -0400
Message-ID: <CADVnQymfM=HZUg_b3brU1iV5V4JLnDKNubLvtADj1j6Y3mxZwg@mail.gmail.com>
References: <20170420214548.23666-1-tracywwnj@gmail.com> <20170420214548.23666-2-tracywwnj@gmail.com>
 <20170420214548.23666-3-tracywwnj@gmail.com> <20170420214548.23666-4-tracywwnj@gmail.com>
 <CAK6E8=eFt_1_jmr75WkVD51NTvgBMaXqu1jBh8i5sEG-cpgy5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:36675 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034868AbdDUDHV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 23:07:21 -0400
Received: by mail-oi0-f42.google.com with SMTP id r203so75797408oib.3
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 20:07:21 -0700 (PDT)
In-Reply-To: <CAK6E8=eFt_1_jmr75WkVD51NTvgBMaXqu1jBh8i5sEG-cpgy5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 5:29 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On Thu, Apr 20, 2017 at 2:45 PM, Wei Wang <weiwan@google.com> wrote:
>> From: Wei Wang <weiwan@google.com>
>>
>> Christoph Paasch from Apple found another firewall issue for TFO:
>> After successful 3WHS using TFO, server and client starts to exchange
>> data. Afterwards, a 10s idle time occurs on this connection. After that,
>> firewall starts to drop every packet on this connection.
>>
>> The fix for this issue is to extend existing firewall blackhole detection
>> logic in tcp_write_timeout() by removing the mss check.
>>
>> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
