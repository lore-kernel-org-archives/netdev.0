From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] network: Allow af_packet to transmit +4 bytes for
 VLAN packets.
Date: Fri, 11 Feb 2011 19:18:56 +0100
Message-ID: <1297448336.2510.9.camel@edumazet-laptop>
References: <1297375149-18458-1-git-send-email-greearb@candelatech.com>
	 <1297375149-18458-2-git-send-email-greearb@candelatech.com>
	 <1297407446.2493.5.camel@edumazet-laptop>
	 <4D557412.7000209@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33531 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757470Ab1BKSTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 13:19:01 -0500
Received: by bwz15 with SMTP id 15so3468454bwz.19
        for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 10:19:00 -0800 (PST)
In-Reply-To: <4D557412.7000209@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 11 f=C3=A9vrier 2011 =C3=A0 09:38 -0800, Ben Greear a =C3=A9=
crit :

> Can you double-check that?  Seems to me that in that method the out_u=
nlock
> falls through to the out_free case.  The other method is the opposite=
, funny
> enough...

Oops you're right, sorry.

Reading again your patch, I see you used one ETH_HLEN instead of
VLAN_HLEN in packet_snd()



