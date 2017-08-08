From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 03/14] sctp: remove the typedef sctp_scope_policy_t
Date: Tue, 8 Aug 2017 14:45:26 +1200
Message-ID: <CADvbK_dC1rRKqyq53Z9Eo8o1q1A7MbmZ3fcVve1TbysB6eUrUw@mail.gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com> <09ffe75e4e16f00b61b682261e2a4b05fa76e814.1501934087.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD004C7B8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35908 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751755AbdHHCp1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 22:45:27 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD004C7B8@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 7, 2017 at 9:28 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Xin Long
>> Sent: 05 August 2017 13:00
>> This patch is to remove the typedef sctp_scope_policy_t and keep
>> it's members as an anonymous enum.
>>
>> It is also to define SCTP_SCOPE_POLICY_MAX to replace the num 3
>> in sysctl.c to make codes clear.
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>>  include/net/sctp/constants.h | 6 ++++--
>>  net/sctp/sysctl.c            | 2 +-
>>  2 files changed, 5 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
>> index 922fba5..acb03eb 100644
>> --- a/include/net/sctp/constants.h
>> +++ b/include/net/sctp/constants.h
>> @@ -341,12 +341,14 @@ typedef enum {
>>       SCTP_SCOPE_UNUSABLE,            /* IPv4 unusable addresses */
>>  } sctp_scope_t;
>>
>> -typedef enum {
>> +enum {
>>       SCTP_SCOPE_POLICY_DISABLE,      /* Disable IPv4 address scoping */
>>       SCTP_SCOPE_POLICY_ENABLE,       /* Enable IPv4 address scoping */
>>       SCTP_SCOPE_POLICY_PRIVATE,      /* Follow draft but allow IPv4 private addresses */
>>       SCTP_SCOPE_POLICY_LINK,         /* Follow draft but allow IPv4 link local addresses */
>> -} sctp_scope_policy_t;
>> +};
>> +
>> +#define SCTP_SCOPE_POLICY_MAX        SCTP_SCOPE_POLICY_LINK
>
> Perhaps slightly better to end the enum with:
>         SCTP_SCOPE_POLICY_COUNT,        /* Number of policies */
>         SCTP_SCOPE_POLICY_MAX = SCTP_SCOPE_POLICY_COUNT - 1     /* Last policy */
> };
It might be, so that new member coming will not change too much.

I just copied the idea of SCTP_EVENT_xxxx_MAX, SCTP_STATE_MAX :-)
