From: Vidya Chowdary <vidya.chowdary@gmail.com>
Subject: Re: [PATCH net-next] net: ethtool: add support for forward error
 correction modes
Date: Sat, 11 Feb 2017 10:53:39 -0800
Message-ID: <CACd6PL3JBs-i-0m5Bx_A0-4DK+ig3sVQsVVP_4hYLo4xwhEE6g@mail.gmail.com>
References: <1486751311-42019-1-git-send-email-vidya@cumulusnetworks.com> <BL2PR07MB2306B8E60E4862D7939586378D470@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "leedom@chelsio.com" <leedom@chelsio.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "dustin@cumulusnetworks.com" <dustin@cumulusnetworks.com>,
        "odedw@mellanox.com" <odedw@mellanox.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>,
        "galp@mellanox.com" <galp@mellanox.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:32955 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdBKSxk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 13:53:40 -0500
Received: by mail-oi0-f68.google.com with SMTP id j15so4497519oih.0
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2017 10:53:40 -0800 (PST)
In-Reply-To: <BL2PR07MB2306B8E60E4862D7939586378D470@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 11, 2017 at 5:33 AM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
>> +/**
>> + * struct ethtool_fecparam - Ethernet forward error correction(fec)
>> +parameters
>> + * @cmd: Command number = %ETHTOOL_GFECPARAM or
>> %ETHTOOL_SFECPARAM
>> + * @active_fec: FEC mode which is active on porte
>> + * @fec: Bitmask of supported/configured FEC modes
>> + * @rsvd: Reserved for future extensions. i.e FEC bypass feature.
>> + *
>> + * Drivers should reject a non-zero setting of @autoneg when
>> + * autoneogotiation is disabled (or not supported) for the link.
>> + *
>> + */
>
> Why request this from drivers?
> Can't you reject such configuration requests in the ethtool-core?
Missed to remove this comment as FEC configuration is completely
decoupled from auto negotiation
and setting of auto negotiation is not required along with FEC
paramters anymore.
Thanks for catching it and will remove the comment in v2 patch if
there are any comments
