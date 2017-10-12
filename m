From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/3] Adding config get/set to devlink
Date: Thu, 12 Oct 2017 12:01:13 -0700 (PDT)
Message-ID: <20171012.120113.825151862740889559.davem@davemloft.net>
References: <CAJieiUjuKtmYDZ5-7UjYkWFJuMGu2gajhziLQKAZLTz6g63f2A@mail.gmail.com>
        <20171012144032.GG14672@nanopsycho>
        <CAJieiUiFmBr72yYP9VNtm0VBTNjJcA6Lj5nHJNBjDBC4moxE2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, steven.lin1@broadcom.com, netdev@vger.kernel.org,
        jiri@mellanox.com, michael.chan@broadcom.com,
        linux-pci@vger.kernel.org, linville@tuxdriver.com,
        gospo@broadcom.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55108 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751900AbdJLTBO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 15:01:14 -0400
In-Reply-To: <CAJieiUiFmBr72yYP9VNtm0VBTNjJcA6Lj5nHJNBjDBC4moxE2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Thu, 12 Oct 2017 07:46:24 -0700

> FWIS, devlink is a driver api just like ethtool is.

Devlink a driver API for doing operations where we don't have a
specific 'netdev' object to work upon.

> and ethtool needs to move to netlink soon...and It would be better to
> not put the rtnl_lock burden on ethtool driver operations. Instead of
> adding yet another driver api, extending devlink seems like a great
> fit to me.

You can use genetlink and avoid RTNL.

Also, Florian Westphal has been pushing the RTNL lock down into the
actual rtnetlink operation implementations.  So one does not have to
avoid rtnetlink to avoid the RTNL mutex at all.
