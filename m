From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Applying inappropriate ioctl operation on socket
 should return ENOTTY
Date: Wed, 27 Apr 2011 07:58:30 +0200
Message-ID: <1303883910.2699.53.camel@edumazet-laptop>
References: <1303882625-28115-1-git-send-email-lifongsun@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Lifeng Sun <lifongsun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62643 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988Ab1D0F6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 01:58:37 -0400
In-Reply-To: <1303882625-28115-1-git-send-email-lifongsun@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 avril 2011 =C3=A0 13:37 +0800, Lifeng Sun a =C3=A9crit :
> ioctl() calls against a socket with an inappropriate ioctl operation
> are incorrectly returning EINVAL rather than ENOTTY:
>=20
>   [ENOTTY]
>       Inappropriate I/O control operation.
>=20
> BugLink: https://bugzilla.kernel.org/show_bug.cgi?id=3D33992
>=20
> This bug is not limited to socket, it also occurs in a lot of, maybe
> some hundred, other ioctl operations, while in the patch I only fixed
> about a dozen of additional ones in pipe, fifo and character device
> drivers.

Really ?

EINVAL is ok too : Request or argp is not valid.

I would say, its not a bug as you claim.=20

Its really too late to make such change and risk regressions.

isatty(fd) performs well. Please use it instead.

Also, networking patches should be sent to netdev@vger.kernel.org and
David Miller, as mentioned in MAINTAINERS file.



