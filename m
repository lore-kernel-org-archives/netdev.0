From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 4/5] net:  Support sending frame with specified FCS.
Date: Sat, 18 Jun 2011 16:44:02 +0200
Message-ID: <1308408242.3539.52.camel@edumazet-laptop>
References: <1308355783-22407-1-git-send-email-greearb@candelatech.com>
	 <1308355783-22407-5-git-send-email-greearb@candelatech.com>
	 <1308376473.3539.37.camel@edumazet-laptop>
	 <4DFCB63F.7030301@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45260 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab1FROoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 10:44:07 -0400
Received: by wwe5 with SMTP id 5so1287917wwe.1
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2011 07:44:06 -0700 (PDT)
In-Reply-To: <4DFCB63F.7030301@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 18 juin 2011 =C3=A0 07:29 -0700, Ben Greear a =C3=A9crit :
> On 06/17/2011 10:54 PM, Eric Dumazet wrote:
> >
> > Please take a look at :
> >
> > arch/*/include/asm/socket.h for many arches.
>=20
> Do I need to update each file, or just make sure the value in
> asm-generic/socket.h is unique for all of them?

You need to update them all.

Check commit 3b885787ea4112 (adding SO_RXQ_OVFL) for reference



