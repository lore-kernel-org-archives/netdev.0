From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net 0/5] sctp: some fixes of prsctp polices
Date: Wed, 28 Sep 2016 11:17:16 -0400 (EDT)
Message-ID: <20160928.111716.1982951742537758888.davem@davemloft.net>
References: <cover.1475059350.git.lucien.xin@gmail.com>
        <20160928.081303.661512609700070565.davem@davemloft.net>
        <CADvbK_eKrZaGf0uDsCBdkWCw9e51W-HVL=_WLsR4RaSKjNmqqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, vyasevich@gmail.com,
        daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36404 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932591AbcI1PR3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 11:17:29 -0400
In-Reply-To: <CADvbK_eKrZaGf0uDsCBdkWCw9e51W-HVL=_WLsR4RaSKjNmqqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 28 Sep 2016 20:35:40 +0800

>>
>>> This patchset is to improve some codes about prsctp polices, and also
>>> to fix some issues.
>>>
>>> v1->v2:
>>>   - wrap the check of chunk->sent_count in a macro:
>>>     sctp_chunk_retransmitted in patch 2/5.
>>
>> This series is a mix of bug fixes (patch #1) which should be targetting
>> 'net' and simplifications/cleanups (patch #2-5) which should be targetting
>> 'net-next'.
>>
>> Please do not mix things up like this, and submit patches targetting
>> the appropriate tree.
>>
> understand, I wanted to divide them.
> but this patchset is special, the following patches
> depend on patch 1/5.

That doesn't matter.  This happens all the time.

The way you handle this is you submit patch #1 targetting 'net' and
wait for it to get into 'net' and propagate into 'net-next'.  When
that happens you can submit patches #2-5 as a second patch series
targetting 'net-next'.
