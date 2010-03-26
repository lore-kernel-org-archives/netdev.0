From: Ulrich Drepper <drepper@gmail.com>
Subject: Re: behavior of recvmmsg() on blocking sockets
Date: Fri, 26 Mar 2010 05:00:11 -0700
Message-ID: <a36005b51003260500v6d8b7a5av1bbba848cc8998a4@mail.gmail.com>
References: <84621a61003241128x3afbcea1w387aeaa68c887320@mail.gmail.com>
	<g76h4xrt5j1pw2kk3tUYAxe124vaj_firegpg@mail.gmail.com> <84621a61003241635h65687366t6b28148281d529c9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Brandon Black <blblack@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f217.google.com ([209.85.217.217]:62414 "EHLO
	mail-gx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165Ab0CZMAc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 08:00:32 -0400
In-Reply-To: <84621a61003241635h65687366t6b28148281d529c9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 24, 2010 at 16:35, Brandon Black <blblack@gmail.com> wrote:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* MSG_WAITF=
ORONE turns on MSG_DONTWAIT after one packet */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!datagrams++ &=
& flags & MSG_WAITFORONE)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 flags |=3D MSG_DONTWAIT;

There should be an extra pair of parenthesis around the & operands but
aside from that I could imagine this to work.

Would be nice if the netdev folks would respond.
