From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 47021] New: kernel panic with l2tpv3 & mtu > 1500
Date: Wed, 05 Sep 2012 10:34:12 +0200
Message-ID: <1346834052.13121.97.camel@edumazet-glaptop>
References: <20120904090756.71b34feb@nehalam.linuxnetplumber.net>
	 <1346788334.13121.82.camel@edumazet-glaptop>
	 <20120904125458.7d97ec38@nehalam.linuxnetplumber.net>
	 <50470324.5040805@atlas.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: a1 <a1bert@atlas.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41506 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990Ab2IEIeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 04:34:18 -0400
Received: by bkwj10 with SMTP id j10so101567bkw.19
        for <netdev@vger.kernel.org>; Wed, 05 Sep 2012 01:34:17 -0700 (PDT)
In-Reply-To: <50470324.5040805@atlas.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-05 at 09:45 +0200, a1 wrote:
> Thanks, it definitely helped, no more panics now...

It seems MTU of device is wrong, and lot of packets are fragmented...

Its currently 1488, but it really should be less than that (accounting
for the IP+UDP header)

I wonder if anybody ever used this code ?
