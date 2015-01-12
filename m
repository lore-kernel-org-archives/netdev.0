From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is received
Date: Mon, 12 Jan 2015 10:02:45 -0500
Message-ID: <CADVnQy=ceATQE=9UCCJmHWaXP9FjMQoCVt_WNxpT9R0C__5BwA@mail.gmail.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
	<1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<54AEA498.5030202@uclouvain.be>
	<CADVnQy=A57TUYD=kGtZXvq7-FGSN=vN3D2heaNCnBB=zjujwUg@mail.gmail.com>
	<1420734325.5947.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAK6E8=dhW=0hRYHjjgBh0KwKOQfzHhwY2egusQ8S4tsoJb0Nsg@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAC5844@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:51540 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbbALPCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 10:02:47 -0500
Received: by mail-qc0-f170.google.com with SMTP id x3so18273142qcv.1
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 07:02:46 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAC5844@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2015 at 6:52 AM, David Laight <David.Laight@aculab.com> wrote:
>>         if (flag & FLAG_DSACKING_ACK) {
>>                 /* This DSACK means original and TLP probe arrived; no loss */
>>                 tp->tlp_high_seq = 0;
>
> I think I'd add a 'return' here.

What's the benefit of adding 'return' in those two spots? That adds
extra code to read, with no change in behavior, and no increase in
maintainability.

neal
