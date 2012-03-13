From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH 4/8] net/mlx4_en: Set max rate-limit for a TC
Date: Tue, 13 Mar 2012 12:16:35 -0700
Message-ID: <CAA93jw425JDVJODhPok8WWNu6ngxGCGAX9ekp6fn8QiA5gq3zA@mail.gmail.com>
References: <1331659323-12904-1-git-send-email-amirv@mellanox.com>
	<1331659323-12904-5-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49543 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758255Ab2CMTQh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 15:16:37 -0400
Received: by wejx9 with SMTP id x9so885221wej.19
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 12:16:36 -0700 (PDT)
In-Reply-To: <1331659323-12904-5-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 13, 2012 at 10:21 AM, Amir Vadai <amirv@mellanox.com> wrote=
:
> From: Amir Vadai <amirv@mellanox.co.il>
>
> Set max rate-limit using sysfs file /sys/class/net/<interface>/qos/ra=
telimit
>
> To set, enter a space separated list of values in units of 100Mbps. =A0=
=46or
> example to set ratelimit of 5G to TC0 and 10G for the reset on eth2 i=
ssue:
> echo 50 100 100 100 100 100 100 100 100 > /sys/class/net/eth2/qos/rat=
elimit

At least in my world, rates go down as low as 128k.

If this 'qos' sys value is intended to be a generic mechanism to be
used instead of (say) htb,
for more than one type of ethernet device.... I would argue that the
units need to be specified.

Similarly what else is intended to live below the 'qos' subdir?
