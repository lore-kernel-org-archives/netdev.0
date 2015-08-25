From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: [PATCH RFC 0/5] net: L2 only interfaces
Date: Tue, 25 Aug 2015 16:44:47 -0700
Message-ID: <CACP96tSxYyWUhAeXTzc49P4Wk3Lr6mr1MMm_7pZQoK4iEdQ5sg@mail.gmail.com>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andrew@lunn.ch,
	linux@roeck-us.net,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	sfeldma@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36298 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbbHYXos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:44:48 -0400
Received: by iodv127 with SMTP id v127so206596765iod.3
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 16:44:47 -0700 (PDT)
In-Reply-To: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 3:50 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Hi all,
>
> This patch series implements a L2 only interface concept which basically denies
> any kind of IP address configuration on these interfaces, but still allows them
> to be used as configuration end-points to keep using ethtool and friends.
>

This is a very interesting idea. A few questions/thoughts: will there
be any eventual restrictions on which types interfaces can be L2_ONLY?
Ideally, it should be possible to let interfaces wink in/out of L2 only
state administratively (as can be done on a typical router, after unwinding
existing config as needed)

I'm assuming something will prevent an L2-only interface from being
part of a vrf.

--Sowmini
