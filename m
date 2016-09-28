From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv2 net 0/5] sctp: some fixes of prsctp polices
Date: Wed, 28 Sep 2016 20:35:40 +0800
Message-ID: <CADvbK_eKrZaGf0uDsCBdkWCw9e51W-HVL=_WLsR4RaSKjNmqqA@mail.gmail.com>
References: <cover.1475059350.git.lucien.xin@gmail.com> <20160928.081303.661512609700070565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vladislav Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:32912 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932273AbcI1Mfm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:35:42 -0400
In-Reply-To: <20160928.081303.661512609700070565.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>> This patchset is to improve some codes about prsctp polices, and also
>> to fix some issues.
>>
>> v1->v2:
>>   - wrap the check of chunk->sent_count in a macro:
>>     sctp_chunk_retransmitted in patch 2/5.
>
> This series is a mix of bug fixes (patch #1) which should be targetting
> 'net' and simplifications/cleanups (patch #2-5) which should be targetting
> 'net-next'.
>
> Please do not mix things up like this, and submit patches targetting
> the appropriate tree.
>
understand, I wanted to divide them.
but this patchset is special, the following patches
depend on patch 1/5.
