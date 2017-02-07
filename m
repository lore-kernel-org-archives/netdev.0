From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/8] mlxsw: cleanup neigh handling
Date: Tue, 7 Feb 2017 10:45:30 +0100
Message-ID: <20170207094530.GA2066@nanopsycho>
References: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
 <20170206.112844.153468141426774611.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36291 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753554AbdBGJpi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 04:45:38 -0500
Received: by mail-wm0-f51.google.com with SMTP id c85so152770220wmi.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 01:45:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170206.112844.153468141426774611.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Feb 06, 2017 at 05:28:44PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Mon,  6 Feb 2017 16:20:09 +0100
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Ido says:
>> 
>> This series addresses long standing issues in the mlxsw driver
>> concerning neighbour reflection. It also prepares the code for follow-up
>> changes dealing with proper resource cleanup and nexthop reflection.
>> 
>> The first two patches convert the neighbour reflection code to use an
>> ordered workqueue, to prevent re-ordering of NEIGH_UPDATE events that
>> may happen following subsequent patches.
>> 
>> The third to fifth patches remove the ndo_neigh_{construct,destroy}
>> entry points from the driver, thereby relying only on NEIGH_UPDATE
>> events for neighbour reflection. This simplifies the code considerably.
>> 
>> Last patches are fallout and adjust nits in the code I noticed while
>> going over it.
>
>Series applied, thanks.
>
>Looks like 6lowpan is the only remaining user of the ndo_neigh_*() ops
>now.

net/atm/clip.c
