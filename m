From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH 2/7] devlink: Adding NPAR permanent config parameters
Date: Thu, 19 Oct 2017 11:12:57 -0400
Message-ID: <CA+Jmh7FEcXij7AEQmWmU8mz_=DW-SYpoyKiSESPW7aeuJuV4fw@mail.gmail.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-3-git-send-email-steven.lin1@broadcom.com> <AM0PR0502MB36839C516E78EF0C2C1E4B46BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>
To: Yuval Mintz <yuvalm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:46590 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752852AbdJSPNS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 11:13:18 -0400
Received: by mail-qt0-f173.google.com with SMTP id 1so14854489qtn.3
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 08:13:18 -0700 (PDT)
In-Reply-To: <AM0PR0502MB36839C516E78EF0C2C1E4B46BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 6:39 AM, Yuval Mintz <yuvalm@mellanox.com> wrote:
>> DEVLINK_ATTR_PERM_CFG_NPAR_BW_RESERVATION_VALID: 1 to use
>> BW_RESERVATION setting, 0 to ignore.
>>
> ...
>> DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT_VALID: 1 to use BW_LIMIT
>> setting, 0 to ignore.
>
> While it probably ties to different fields in your NVM layout why would the user
> require specific attributes for these? Why not have values in the actual
> attributes indicating of this status?

Hi Yuval,

Does having the separate valid flag present any difficulties?  There
are lots of implementation options here (a limit or reservation value
of 0 could mean invalid, or we could define (1 << 31) to be a valid
flag when setting the value, etc.), and I'm not necessarily tied to
doing it this way, but it seemed a straightforward way to represent
the validity of the other field.

Thanks again,
Steve
