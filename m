From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/9] mlxsw: Support firmware flash
Date: Tue, 23 May 2017 17:52:47 +0200
Message-ID: <20170523155247.GJ1829@nanopsycho>
References: <ea7cf005-1f6c-aa87-db90-03d7c77c7d56@mellanox.com>
 <BLUPR0701MB2004EB2F32B4C8C42C5020458DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
 <fba5a440-ba1e-84bd-d2d2-d011406d3a4a@mellanox.com>
 <20170523.113859.1803057381093280239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yotamg@mellanox.com, Yuval.Mintz@cavium.com,
        netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com,
        bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34826 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759865AbdEWPwt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:52:49 -0400
Received: by mail-wm0-f67.google.com with SMTP id g15so20800527wmc.2
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 08:52:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170523.113859.1803057381093280239.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 23, 2017 at 05:38:59PM CEST, davem@davemloft.net wrote:
>From: Yotam Gigi <yotamg@mellanox.com>
>Date: Tue, 23 May 2017 18:14:15 +0300
>
>> Sorry, I am not sure I understand. You think that drivers should not implement
>> ethtool's flash_device callback anymore? do you have an alternative for firmware
>> flash?
>
>As stated, export an MTD device.

Okay. We'll cut out the ethtool part of the patchset and will do mtd as
a followup. Thanks
