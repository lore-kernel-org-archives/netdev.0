From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 07/11] net: dsa: mv88e6xxx: add port link setter
Date: Wed, 02 Nov 2016 02:07:09 +0100
Message-ID: <87shra4rlu.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161101032023.32762-1-vivien.didelot@savoirfairelinux.com> <20161101032023.32762-8-vivien.didelot@savoirfairelinux.com> <20161101094313.GB2802@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:38436 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754489AbcKBBHP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 21:07:15 -0400
In-Reply-To: <20161101094313.GB2802@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> +#define LINK_UNKNOWN	-1
>> +
>> +	/* Port's MAC link state
>> +	 * LINK_UNKNOWN for normal link detection, 0 to force link down,
>> +	 * otherwise force link up.
>> +	 */
>> +	int (*port_set_link)(struct mv88e6xxx_chip *chip, int port, int link);
>
> Maybe LINK_AUTO would be better than UNKNOWN? Or LINK_UNFORCED.

I used LINK_UNKNOWN to be consistent with the supported SPEED_UNKNOWN
and DUPLEX_UNKNOWN values of PHY devices.

Thanks,

        Vivien
