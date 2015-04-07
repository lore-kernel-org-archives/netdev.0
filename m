From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next v1] bonding: cosmetic/readability changes for
 admin, oper-key ops
Date: Tue, 7 Apr 2015 11:08:07 -0700
Message-ID: <CAF2d9jgJQ-xKNBQmt-3LVt=Yg_taLpLnTrvFBkjUhz_HgUh0sg@mail.gmail.com>
References: <1428094440-9241-1-git-send-email-maheshb@google.com> <20150406.170106.811076629093466625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:36141 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847AbbDGSIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 14:08:35 -0400
Received: by obbeb7 with SMTP id eb7so28149102obb.3
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 11:08:34 -0700 (PDT)
In-Reply-To: <20150406.170106.811076629093466625.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 6, 2015 at 2:01 PM, David Miller <davem@davemloft.net> wrote:
> From: Mahesh Bandewar <maheshb@google.com>
> Date: Fri,  3 Apr 2015 13:54:00 -0700
>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>
> This is a very low quality patch submission.
>
> You aren't explaining what you are really doing, or why.
>
> Furthermore:
>
>> @@ -1756,8 +1758,6 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
>>               port->actor_system_priority = 0xffff;
>>               port->actor_port_aggregator_identifier = 0;
>>               port->ntt = false;
>> -             port->actor_admin_port_key = 1;
>> -             port->actor_oper_port_key  = 1;
>>               port->actor_admin_port_state = AD_STATE_AGGREGATION |
>>                                              AD_STATE_LACP_ACTIVITY;
>>               port->actor_oper_port_state  = AD_STATE_AGGREGATION |
>
> This is not just a readability or cosmetic change, it is changing behavior.
>
> You need to describe why removing these initializers is valid, and also
> this change is outside of the scope of a cosmetic/readability change so
> would need to be split into another patch.
>
> It is almost never correct to have an empty commit log message, espcially
> when real changes are being made to the code as is happening here in this
> code block.

These are bogus initializers but I agree that this piece deserves a
separate patch with an explanation. Rest of the patch is nothing but
code-re-factoring (breaking rich assignment to simpler, multiple
assignments, removing duplicate code etc.) to make it readable. I
though it wont be necessary to add that into the commit log since it's
very obvious hence I kept it empty.  Will break it into two patches
and send it again.

Thanks,
--mahesh..
