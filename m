From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: 3.6.10 tcp crash - net/ipv4/tcp.c:1667 & tcp.c:1655
Date: Mon, 17 Dec 2012 11:34:13 -0800
Message-ID: <1355772853.9380.10.camel@edumazet-glaptop>
References: <20121217174145.GH22452@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64819 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939Ab2LQTeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 14:34:16 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so4246298pbc.19
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2012 11:34:15 -0800 (PST)
In-Reply-To: <20121217174145.GH22452@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-17 at 12:41 -0500, Benjamin LaHaise wrote:
> Hi folks,
> 
> I just hit the following crash with Fedora's 3.6.10-2.fc17 kernel.  I don't 
> have time to debug this myself at the moment, but can certainly test patches 
> or provide more info as needed.  I wasn't doing anything unusual at the time, 
> just reading email/web browsing.  I believe the network driver in use was 
> ipheth for tethering to an iPhone 4S over USB (the other driver being used 
> intermittently on this laptop is iwlwifi).  Any ideas?

I see nothing really wrong on ipheth side.

I would be nice to know which driver is really in use when you have a
panic, as its probably a driver issue.
