From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Tue, 10 Nov 2015 21:41:54 -0800
Message-ID: <CALx6S34PkfKS47_FxuqwDbqP9P0C5J7YRR5e_-BLjfkPwPRgXw@mail.gmail.com>
References: <1443313848-751-1-git-send-email-tolga.ceylan@gmail.com>
	<877fnc7i0i.fsf@bytheb.org>
	<CALmu+Sx8L5mWf3Nnbz=x0qt7pC5n5oVPRJd7dnLATVpmmO+nrA@mail.gmail.com>
	<1443320655.3273.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33538 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbbKKFlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 00:41:55 -0500
Received: by iouu10 with SMTP id u10so16481287iou.0
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 21:41:54 -0800 (PST)
In-Reply-To: <1443320655.3273.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tolga, are you still planning to respin this patch (when tree opens?)

Thanks,
Tom


On Sat, Sep 26, 2015 at 7:24 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2015-09-26 at 19:02 -0700, Tolga Ceylan wrote:
>> By keeping hiscore/matches as is, I'm trying to keep the hashing consistent.
>> Otherwise, this would behave similar to removing a listener which
>> drops connections.
>
> Right, this problem will soon disappear when listener rewrite is
> complete.
>
> Only SYN packet will have to select a listener.
>
> Then when ACK packet comes, the SYN_RECV will be found in ehash table,
> and req->rsk_listener will be used to get the listener that was chosen
> at SYN time.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
