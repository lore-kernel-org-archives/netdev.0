From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net 2/5] sctp: reuse sent_count to avoid retransmitted
 chunks for RTT measurements
Date: Tue, 27 Sep 2016 17:54:07 +0800
Message-ID: <CADvbK_fFkn1PcRnRg2PJnCEnhLfojSHp+LCKCWWwxM_xi-fJfQ@mail.gmail.com>
References: <cover.1474883200.git.lucien.xin@gmail.com> <e8146a7075544ccb2631117f507cfd51e20b4cde.1474883200.git.lucien.xin@gmail.com>
 <20160926131300.GA6812@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:36788 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933354AbcI0JyI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 05:54:08 -0400
In-Reply-To: <20160926131300.GA6812@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Maybe wrap this in a macro?  i.e.:
> #define chunk_retransmitted(chunk) (chunk->sent_count > 1)
>
> For readability?
>
That's a nice suggestion.
chunk->sent_count == 1 is confusing there for reading.
will improve it in v2.

Thanks.
