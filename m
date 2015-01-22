From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netxen: box stuck in netxen_napi_disable()
Date: Wed, 21 Jan 2015 22:52:00 -0800
Message-ID: <1421909520.3471.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421901805.5286.37.camel@marge.simpson.net>
	 <1421906274.4832.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1421907358.5286.42.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:52357 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbbAVGwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 01:52:03 -0500
Received: by mail-pa0-f52.google.com with SMTP id kx10so27558223pab.11
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 22:52:02 -0800 (PST)
In-Reply-To: <1421907358.5286.42.camel@marge.simpson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-22 at 07:15 +0100, Mike Galbraith wrote:
> On Wed, 2015-01-21 at 21:57 -0800, Eric Dumazet wrote:
> 
> > This driver doesn't follow the NAPI model correctly.
> > 
> > Please try following fix :
> 
> Thanks Eric, I'll plug it in in a bit and poke at it.  No news is good
> news, as good as news gets for unknown repeatability bugs that is ;-)

To trigger the bug, all you had to do was to stress the transmit side.

You could reduce MAX_STATUS_HANDLE from 64 to 4 to trigger it even
faster.

I'll send an official patch tomorrow morning.

Thanks !
