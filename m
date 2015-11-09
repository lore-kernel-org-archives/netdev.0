From: "=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?=" <bro.devel@gmail.com>
Subject: Re: [PATCH RFC net-next 0/2] tcp: Redundant Data Bundling (RDB)
Date: Mon, 9 Nov 2015 20:40:41 +0100
Message-ID: <5640F6B9.4030306@gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
 <CAK6E8=eSYoxo6BLPh=jpmfudcRSJ3uT3YhZ0n-XP_dnxKCNH3A@mail.gmail.com>
 <61F74109-9FDC-485A-978B-714B7AA27445@ifi.uio.no>
 <1445691445.22974.200.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jonas Markussen <jonassm@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>,
	=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?= <bro.devel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	netdev <netdev@vger.kernel.org>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=c3=a5l_Halvorsen?= <paalh@simula.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f194.google.com ([209.85.217.194]:35730 "EHLO
	mail-lb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371AbbKITky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 14:40:54 -0500
Received: by lblw10 with SMTP id w10so8000527lbl.2
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2015 11:40:52 -0800 (PST)
In-Reply-To: <1445691445.22974.200.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/10/15 14:57, Eric Dumazet wrote:
> Thank you for this very high quality patch submission.
>
> Please give us a few days for proper evaluation.
>
> Thanks !

Guys, thank you very much for taking the time to evaluate this.

Since there haven't been any more feedback or comments I'll submit an
RFCv2 with a few changes which includes removing the Nagle
modification.

After discussing the Nagle change on setsockopt we realize that it
should be evaluated more thoroughly, and is better left for a later
patch submission.

Bendik

P.S.
Trimming the CC list to only those who have responded as gmail says
I'm spamming :-)
