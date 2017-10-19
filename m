From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH 4/7] devlink: Adding perm config of link settings
Date: Thu, 19 Oct 2017 11:07:50 -0400
Message-ID: <CA+Jmh7H+u1-1Ot2TxLXEHk2HW=p+yeT02cexNPC1nW5V_gMVgQ@mail.gmail.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-5-git-send-email-steven.lin1@broadcom.com> <AM0PR0502MB36835F863A3E05376F3562B1BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
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
Received: from mail-qt0-f169.google.com ([209.85.216.169]:52815 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbdJSPIL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 11:08:11 -0400
Received: by mail-qt0-f169.google.com with SMTP id 31so14797967qtz.9
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 08:08:11 -0700 (PDT)
In-Reply-To: <AM0PR0502MB36835F863A3E05376F3562B1BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 2:07 AM, Yuval Mintz <yuvalm@mellanox.com> wrote:
>> +enum devlink_autoneg_protocol {
>> +     DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY_BAM,
>> +     DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY_CONSORTIUM,
>> +     DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY,
>> +     DEVLINK_AUTONEG_PROTOCOL_BAM,           /* Broadcom
>> Autoneg Mode */
>> +     DEVLINK_AUTONEG_PROTOCOL_CONSORTIUM,    /*
>> Consortium Autoneg Mode */
>> +};
>
> Wouldn't adding BAM as a 'generic' mode of operation be like adding
> non-consortium speeds to ethtool API?
> [I profess ignorance in this area; For all I know it can be a widely accepted
> industry standard]
>

Yuval, I'm glad to get input from other NIC vendors.  The high-level
goal of this effort is to allow users of various vendors' NICs to be
able to configure these types of NVRAM/permanent/default settings
using an inbox tool, rather than the collection of vendor-specific
tools that is the status quo.

In order to provide that functionality, it seems like the
vendor-specific parameters and also the vendor-specific settings of
common parameters both need to be supported in this manner.

Ideally there will be much overlap in both the set of parameters
available as well as the options for each parameter, but in the real
world, there will always be differences between vendors and even
between different devices (drivers) from the same vendor.  Despite
that reality, I think there is still great benefit in having a common
inbox tool that users can use for device configuration of this type.
It just means that not all drivers will support all parameters, nor
all options for each parameter that they do support.

Thanks,
Steve
