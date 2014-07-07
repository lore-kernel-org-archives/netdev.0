From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2 7/8] net-timestamp: expand documentation
Date: Mon, 7 Jul 2014 11:40:15 -0400
Message-ID: <CA+FuTSezD0c2t_tp11VPvRt+RpsQkqhPCF5oaKb60eUVdFP_pA@mail.gmail.com>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
 <1404416380-3545-8-git-send-email-willemb@google.com> <20140705201429.GD3869@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:56100 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbaGGPkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 11:40:46 -0400
Received: by mail-qg0-f53.google.com with SMTP id i50so3832170qgf.40
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2014 08:40:45 -0700 (PDT)
In-Reply-To: <20140705201429.GD3869@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 5, 2014 at 4:14 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Thu, Jul 03, 2014 at 03:39:39PM -0400, Willem de Bruijn wrote:
>
>> -hwtimetrans is the hardware time stamp transformed so that it
>> +SCM_TSTAMP_HWRAW is the hardware time stamp transformed so that it
>>  corresponds as good as possible to system time. This correlation is
>>  not perfect; as a consequence, sorting packets received via different
>>  NICs by their hwtimetrans may differ from the order in which they were
>
> While we are at it, I would like to replace this text with something
> like "legacy field, always zero."

Judging from the octeon code, it may be non-zero. Perhaps

"Deprecated field. It is always zero on all but one platform and not
supported for new platform development. Applications should not use
this field."
>
> Thanks,
> Richard
>
