From: Ed Swierk <eswierk@bigswitch.com>
Subject: Re: bridge: allow forwarding LLDP frames
Date: Fri, 4 Nov 2011 06:50:19 -0700
Message-ID: <CAF5U64A0R0o2duJYU=7w-G77dfgzoeWkeLKwt21WJeABhwf8VQ@mail.gmail.com>
References: <20111017181207.06081E3280@meep> <CAEJpZP2oGUYW_i+7qYxyD8th_YdGo5+nZaevceYJJxGWsR5c2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, davem@davemloft.net, netdev@vger.kernel.org
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:50891 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932322Ab1KDNvA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 09:51:00 -0400
Received: by vcbf1 with SMTP id f1so339581vcb.19
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2011 06:51:00 -0700 (PDT)
In-Reply-To: <CAEJpZP2oGUYW_i+7qYxyD8th_YdGo5+nZaevceYJJxGWsR5c2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 3, 2011 at 3:17 PM, Nick Carter <ncarter100@gmail.com> wrot=
e:
> The reason the group fwd mask was introduced was to make the bridge
> forward link local group addresses. =C2=A0This is non standards based
> behaviour. =C2=A0The point of the group fwd mask is so that users can=
 have
> non standard bridging behaviour.
>
> I don't understand why the recent commit includes blocking the user
> from choosing to forward certain groups because it breaks standards ?
> The default mask of 0 is standards based behaviour. =C2=A0If the user=
 sets
> it to anything other than 0 then they want non standards based
> behaviour.
>
> In my view the behaviour now is very confusing for the user. =C2=A080=
2.1X
> is allowed to be forwarded but LLDP forwarding is rejected ?
>
> The group fwd mask should be allowed to be set to any value. =C2=A0Th=
is
> would give flexible and predictable behaviour to the user.
>
> I think we should assume users know the behaviour they require and
> BR_GROUPFWD_RESTRICTED should be removed from the codebase.

+1

It doesn't make sense to go out of our way to forbid users from
enabling forwarding of three magic addresses. Removing the restriction
would simplify the code and simplify the behavior.

--Ed
