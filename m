From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/8] Add support for pipeline debug (dpipe)
Date: Thu, 16 Feb 2017 17:48:35 +0100
Message-ID: <20170216164835.GH1968@nanopsycho>
References: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
 <20170216161150.GC17550@lunn.ch>
 <20170216162000.GF1968@nanopsycho>
 <20170216164029.GE17550@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, roopa@cumulusnetworks.com,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        john.fastabend@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36369 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932358AbdBPQsi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 11:48:38 -0500
Received: by mail-wm0-f65.google.com with SMTP id r18so4010657wmd.3
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 08:48:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170216164029.GE17550@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 16, 2017 at 05:40:29PM CET, andrew@lunn.ch wrote:
>On Thu, Feb 16, 2017 at 05:20:00PM +0100, Jiri Pirko wrote:
>> Thu, Feb 16, 2017 at 05:11:50PM CET, andrew@lunn.ch wrote:
>> >On Thu, Feb 16, 2017 at 04:22:36PM +0100, Jiri Pirko wrote:
>> >> From: Jiri Pirko <jiri@mellanox.com>
>> >> 
>> >> Arkadi says:
>> >
>> >Hi Jiri, Arkadi
>> >
>> >It is not mentioned here, but i assume you have a followup patchset
>> >which extends the devlink command to enumerate what tables are
>> >available and to print them?
>> 
>> DEVLINK_CMD_DPIPE_TABLES_GET
>> command gets you all tables. But it gets it with the content. I guess
>> there could be some command to instruct devlink just to dump tables
>> without the content.
>
>This does not sound like it will scale very well, as the number of
>tables increases. Also, at least in the DSA world, getting a table can
>be an expensive operation, lots of MDIO/SPI/I2C transactions. I'd
>prefer to be able to just get one specific table, rather than dump
>them all.

Understood. We'll try to figure out how to make this done.


>
>I can however see cases when it does make sense to have an atomic,
>dump everything operation, where you can trust to be consistent across
>tables.
>
>> >Hopefully it will be more obvious when the user space patches are
>> >available.
>> 
>> I'll ask Arkadi to send the devlink userspace patches as RFC as well.
>
>Great, thanks.
>
>       Andrew
