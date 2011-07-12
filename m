From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC v2 2/2] e100: Support RXFCS feature flag.
Date: Tue, 12 Jul 2011 09:00:00 -0700
Message-ID: <20110712090000.29c17c20@nehalam.ftrdhcpuser.net>
References: <1308942371-12748-1-git-send-email-greearb@candelatech.com>
	<1308942371-12748-3-git-send-email-greearb@candelatech.com>
	<BANLkTiknCV1HknVpEdK97yU8eJwaJ5Y5Ag@mail.gmail.com>
	<4E0B3510.2080202@candelatech.com>
	<BANLkTikaJNa2+jbW6HWwc+tEE-ciNxvkLg@mail.gmail.com>
	<4E0B383E.8020807@candelatech.com>
	<BANLkTi=-ibpBiWBZ=AANybmWMWfMVGfe4Q@mail.gmail.com>
	<4E0B42CE.30400@candelatech.com>
	<CAHXqBFL-QgKvrvcrjtjSgDdeH9i7Ai86U2ujQ4xpo-vXLEkO5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: =?ISO-8859-2?B?TWljaGGzIE1pcm9zs2F3?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53167 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753262Ab1GLQAA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 12:00:00 -0400
In-Reply-To: <CAHXqBFL-QgKvrvcrjtjSgDdeH9i7Ai86U2ujQ4xpo-vXLEkO5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jul 2011 17:49:49 +0200
Micha=B3 Miros=B3aw <mirqus@gmail.com> wrote:

> wanted_features only reflects what is requested by user, this
> combination might be invalid. When conditions change this value
> combined with other bits in features are passed through
> ndo_fix_features callback and netdev_fix_features() to bring it to
> valid state, and then (if resulting set is different than current
> features) ndo_set_features() is called to reconfigure device for that
> new state change to it.

Since this semantic is more complicated than most other parts
of network device interface API; could you please put a detailed
documentation into Documentation/networking/netdevices.txt

The whole netdevices.txt document could use some extending and
rewriting as well.
