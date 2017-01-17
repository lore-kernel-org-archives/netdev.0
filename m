From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv3 net-next 1/7] sctp: add a common helper function to
 generate stream reconf chunk
Date: Tue, 17 Jan 2017 11:41:32 +0800
Message-ID: <CADvbK_ef7RQ7x+jePniWC27m=giAyTdZH+vuuoQNEs1mX3=NXg@mail.gmail.com>
References: <cover.1484334002.git.lucien.xin@gmail.com> <5f8a7d818b5db99f2ff2a791a451b311c09fad7f.1484334002.git.lucien.xin@gmail.com>
 <20170116.135033.773805315875747960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:32831 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750827AbdAQDld (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 22:41:33 -0500
In-Reply-To: <20170116.135033.773805315875747960.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 2:50 AM, David Miller <davem@davemloft.net> wrote:
> From: Xin Long <lucien.xin@gmail.com>
> Date: Sat, 14 Jan 2017 03:15:35 +0800
>
>> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
>> index a15d824..fd58097 100644
>> --- a/net/sctp/sm_make_chunk.c
>> +++ b/net/sctp/sm_make_chunk.c
>> @@ -3526,3 +3526,36 @@ struct sctp_chunk *sctp_make_fwdtsn(const struct sctp_association *asoc,
>>
>>       return retval;
>>  }
>> +
>> +/* RE-CONFIG 3.1 (RE-CONFIG chunk)
>> + *   0                   1                   2                   3
>> + *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
>> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>> + *  | Type = 130    |  Chunk Flags  |      Chunk Length             |
>> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>> + *  \                                                               \
>> + *  /                  Re-configuration Parameter                   /
>> + *  \                                                               \
>> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>> + *  \                                                               \
>> + *  /             Re-configuration Parameter (optional)             /
>> + *  \                                                               \
>> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>> + */
>> +static struct sctp_chunk *sctp_make_reconf(
>> +                             const struct sctp_association *asoc,
>> +                             int length)
>> +{
>> +     struct sctp_reconf_chunk *reconf;
>
> This patch will cause a warning because this new static function is unused.
>
> All patch series must be fully bisectable, that measn at each step of
> the patch series the tree must work properly and not introduce new
> build warnings or build failures.
sorry, will merge patch 1/7 and 2/7
