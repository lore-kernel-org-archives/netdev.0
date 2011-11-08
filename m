From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net-netlink: Add a new attribute to expose TCLASS
 values via netlink
Date: Mon, 7 Nov 2011 16:27:04 -0800
Message-ID: <20111107162704.0b569074@nehalam.linuxnetplumber.net>
References: <1320711791-11005-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <maze@google.com>,
	netdev@vger.kernel.org, Murali Raja <muralira@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45403 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371Ab1KHA1H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 19:27:07 -0500
In-Reply-To: <1320711791-11005-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  7 Nov 2011 16:23:11 -0800
Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:

> commit 3ceca749668a52bd795585e0f71c6f0b04814f7b added a TOS attribute=
=2E
>=20
> Unfortunately TOS and TCLASS are both present in a dual-stack v6 sock=
et,
> furthermore they can have different values.  As such one cannot in a
> sane way expose both through a single attribute.

Do we really want to continue to expose that as a supported
API. I would argue it was a mistake in the original implementation.
