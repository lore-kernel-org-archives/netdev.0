From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Sat, 14 Jan 2017 12:46:42 -0500
Message-ID: <d18e9e5b-8781-6054-b42f-75cad3720c04@mojatatu.com>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <586A9A9F.4030002@gmail.com>
 <6b671aaf-d35d-70a5-65e0-40308baeb471@mojatatu.com>
 <20170108171902.GH1971@nanopsycho> <5873D523.4030301@gmail.com>
 <68e41fe4-5c4c-e159-fbfc-17d06638707d@mojatatu.com>
 <20170114144855.GA1886@nanopsycho.orion>
 <de59c019-8a7d-6747-ddc1-9a21f40d3e04@mojatatu.com>
 <20170114152918.GC1886@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Paul Blakey <paulb@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34089 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdANRqp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 12:46:45 -0500
Received: by mail-io0-f196.google.com with SMTP id c80so8705415iod.1
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 09:46:45 -0800 (PST)
In-Reply-To: <20170114152918.GC1886@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-14 10:29 AM, Jiri Pirko wrote:
> Sat, Jan 14, 2017 at 04:03:17PM CET, jhs@mojatatu.com wrote:

> Fair. So could this be done like IFLA_PHYS_SWITCH_ID and
> IFLA_PHYS_PORT_ID. They can have variable size, max is MAX_PHYS_ITEM_ID_LEN
>
> We can let user to pass arbitrary len up to 16 bytes. This has benefit in
> fact that if in future this needs to be extended to say 32 bytes, it is
> backward compatible. We just change the check in kernel.
>

Sure. Ive run out of time for now; but will work on a new version later.

cheers,
jamal
