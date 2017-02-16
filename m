From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/8] Add support for pipeline debug (dpipe)
Date: Thu, 16 Feb 2017 17:20:00 +0100
Message-ID: <20170216162000.GF1968@nanopsycho>
References: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
 <20170216161150.GC17550@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, roopa@cumulusnetworks.com,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        john.fastabend@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33271 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932725AbdBPQUF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 11:20:05 -0500
Received: by mail-wr0-f196.google.com with SMTP id i10so2655008wrb.0
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 08:20:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170216161150.GC17550@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 16, 2017 at 05:11:50PM CET, andrew@lunn.ch wrote:
>On Thu, Feb 16, 2017 at 04:22:36PM +0100, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Arkadi says:
>
>Hi Jiri, Arkadi
>
>It is not mentioned here, but i assume you have a followup patchset
>which extends the devlink command to enumerate what tables are
>available and to print them?

DEVLINK_CMD_DPIPE_TABLES_GET
command gets you all tables. But it gets it with the content. I guess
there could be some command to instruct devlink just to dump tables
without the content.


>
>What i seem to be missing is headers in uapi which links kernel and
>userspace together. There are lots of enums defined, but few seem to
>be exported to user space for the table parser/printer to use.

Not needed. All info is passed via devlink interface.


>
>Hopefully it will be more obvious when the user space patches are
>available.

I'll ask Arkadi to send the devlink userspace patches as RFC as well.
