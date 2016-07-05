From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 3/4] net: dsa: Suffix function manipulating
 device_node with _dn
Date: Tue, 5 Jul 2016 15:43:35 -0700
Message-ID: <577C3817.1070908@gmail.com>
References: <1467756433-25062-1-git-send-email-f.fainelli@gmail.com>
 <1467756433-25062-4-git-send-email-f.fainelli@gmail.com>
 <20160705223612.GC28825@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34521 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbcGEWnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 18:43:49 -0400
Received: by mail-pa0-f51.google.com with SMTP id bz2so70982055pad.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 15:43:38 -0700 (PDT)
In-Reply-To: <20160705223612.GC28825@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2016 03:36 PM, Andrew Lunn wrote:
> On Tue, Jul 05, 2016 at 03:07:12PM -0700, Florian Fainelli wrote:
>> Make it clear that these functions take a device_node structure pointer
> 
> Hi Florian
> 
> Didn't we agree that we would only support a single device via a C
> coded platform data structure?

That is true for the devices I know about, both in and out of tree,
however, while discussing offline with Vivien it seemed like there was a
potential need for having a x86-based platform which could need that,
Vivien do you think this platform could be in-tree one day (if not already)?

> 
> All the functions you are renaming will never be called in that
> case. So i think they can retain there names. You have no need to add
> none device node equivalents.
> 
> So lets drop this patch.
> 
>    Andrew
> 


-- 
Florian
