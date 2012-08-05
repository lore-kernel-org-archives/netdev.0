From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: Bridge extensions to iproute2
Date: Sun, 5 Aug 2012 00:27:36 -0700
Message-ID: <CAHo-OowanCoYkNiyGs1aYMAmxLcEXRZeeZ3WMxi+HaCZTXUCTw@mail.gmail.com>
References: <meqjoqmsb19c7jsv7pbldsjc.1344134703305@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:49033 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648Ab2HEH1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Aug 2012 03:27:37 -0400
Received: by obbuo13 with SMTP id uo13so3876033obb.19
        for <netdev@vger.kernel.org>; Sun, 05 Aug 2012 00:27:36 -0700 (PDT)
In-Reply-To: <meqjoqmsb19c7jsv7pbldsjc.1344134703305@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, there really isn't much reason for bridge configuration to be a
separate package than iproute, seeing how there's vlan/veth etc
configuration built into 'ip'

On Sat, Aug 4, 2012 at 7:45 PM, Stephen Hemminger
<stephen.hemminger@vyatta.com> wrote:
> There is barely any overlap between bridge-utils and iproute2.
> I was thinking of making a script 'brctl' that does same thing as
> old utility but using new netlink based commands.
>
