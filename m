From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: Implement ndo_get_phys_port_name()
Date: Tue, 10 Jan 2017 15:58:45 -0500
Message-ID: <87pojuhbsq.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170110203237.23907-1-f.fainelli@gmail.com> <20170110203237.23907-2-f.fainelli@gmail.com> <20170110205043.GM22820@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:47196 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750700AbdAJU7K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:59:10 -0500
In-Reply-To: <20170110205043.GM22820@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Tue, Jan 10, 2017 at 12:32:36PM -0800, Florian Fainelli wrote:
>> Return the physical port number of a DSA created network device using
>> ndo_get_phys_port_name().
>
> At what level does this need to be unique?

The port name must be unique at the switch Linux device level.

Thanks,

        Vivien
