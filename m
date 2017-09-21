From: Grant Edwards <grant.b.edwards@gmail.com>
Subject: Re: net: macb: fail when there's no PHY
Date: Thu, 21 Sep 2017 15:36:08 -0500
Message-ID: <20170921203608.GB30148@grante>
References: <20170921195905.GA29873@grante>
 <66c0a032-4d20-69f1-deb4-6c65af6ec740@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:57228 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751707AbdIUUgL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 16:36:11 -0400
Received: by mail-io0-f180.google.com with SMTP id m103so13594144iod.13
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 13:36:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <66c0a032-4d20-69f1-deb4-6c65af6ec740@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 01:05:57PM -0700, Florian Fainelli wrote:

>> It looks like the macb driver still can't handle boards that don't
>> have a PHY.  Is that correct?
> 
> Not since:
> 
> dacdbb4dfc1a1a1378df8ebc914d4fe82259ed46 ("net: macb: add fixed-link
> node support")

Yep, it's obvious now that I've got the diff in front of me.

Thanks!

[I just started working with device tree for the first time yesterday,
and I must say it's way better than the "old days" which required all
sorts of ugly to produce a kernel that could work on two slightly
different boards.]

-- 
Grant
