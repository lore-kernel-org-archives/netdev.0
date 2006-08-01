From: "Jeff Kirsher" <tarbal@gmail.com>
Subject: Re: e1000 speed/duplex error
Date: Tue, 1 Aug 2006 04:20:28 -0700
Message-ID: <9929d2390608010420t60bd44d7o4e522c6edc0a677e@mail.gmail.com>
References: <1301563340.20060801141827@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:55481 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932641AbWHALUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 07:20:30 -0400
Received: by ug-out-1314.google.com with SMTP id m3so1247683ugc
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2006 04:20:28 -0700 (PDT)
To: a1 <a1k@mail.ru>
In-Reply-To: <1301563340.20060801141827@mail.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/1/06, a1 <a1k@mail.ru> wrote:
> I'm trying to set my nic to force 100Mb/FD, but I'm constantly getting 100/HD on
> other side of the link.
>
> The command is:
> ethtool -s eth0 speed 100 duplex full autoneg off
>
> e1000 driver version 7.1.9 (latest) downloaded from sourceforge.
>

What are you linking to? And what is the link partner set to?

If one link partner is set to auto-negotiate, and the other partner
forced, it is common to see this issue no matter what the two link
partners are.

> Are there any problems?

Not that I am aware of.

-- 
Cheers,
Jeff
