From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next RFC 0/8] Add support for pipeline debug (dpipe)
Date: Thu, 16 Feb 2017 17:40:29 +0100
Message-ID: <20170216164029.GE17550@lunn.ch>
References: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
 <20170216161150.GC17550@lunn.ch>
 <20170216162000.GF1968@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, roopa@cumulusnetworks.com,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        john.fastabend@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42076 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932386AbdBPQkc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 11:40:32 -0500
Content-Disposition: inline
In-Reply-To: <20170216162000.GF1968@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2017 at 05:20:00PM +0100, Jiri Pirko wrote:
> Thu, Feb 16, 2017 at 05:11:50PM CET, andrew@lunn.ch wrote:
> >On Thu, Feb 16, 2017 at 04:22:36PM +0100, Jiri Pirko wrote:
> >> From: Jiri Pirko <jiri@mellanox.com>
> >> 
> >> Arkadi says:
> >
> >Hi Jiri, Arkadi
> >
> >It is not mentioned here, but i assume you have a followup patchset
> >which extends the devlink command to enumerate what tables are
> >available and to print them?
> 
> DEVLINK_CMD_DPIPE_TABLES_GET
> command gets you all tables. But it gets it with the content. I guess
> there could be some command to instruct devlink just to dump tables
> without the content.

This does not sound like it will scale very well, as the number of
tables increases. Also, at least in the DSA world, getting a table can
be an expensive operation, lots of MDIO/SPI/I2C transactions. I'd
prefer to be able to just get one specific table, rather than dump
them all.

I can however see cases when it does make sense to have an atomic,
dump everything operation, where you can trust to be consistent across
tables.

> >Hopefully it will be more obvious when the user space patches are
> >available.
> 
> I'll ask Arkadi to send the devlink userspace patches as RFC as well.

Great, thanks.

       Andrew
