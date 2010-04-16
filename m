From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 09:48:17 +0200
Message-ID: <1271404097.16881.3827.camel@edumazet-laptop>
References: <20100415.233334.242114544.davem@davemloft.net>
	 <1271401007.16881.3762.camel@edumazet-laptop>
	 <1271402283.16881.3791.camel@edumazet-laptop>
	 <20100416.002632.83844236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:56266 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754348Ab0DPHs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 03:48:28 -0400
Received: by bwz25 with SMTP id 25so2648752bwz.28
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 00:48:26 -0700 (PDT)
In-Reply-To: <20100416.002632.83844236.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 avril 2010 =C3=A0 00:26 -0700, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 16 Apr 2010 09:18:03 +0200
>=20
> > Hmm, I wonder if its not an artifact of net-next-2.6 being a bit ol=
d
> > (versus linux-2.6). I know scheduler guys did some tweaks.
>=20
> I synced net-next-2.6 up with Linus's current tree just a day
> or two ago when I pulled net-2.6 into net-next-2.6.

OK thanks :)

Tom, please add a read_mostly to rps_sock_flow_table

struct rps_sock_flow_table *rps_sock_flow_table __read_mostly;

I'll spend some hours today to track the problem.



