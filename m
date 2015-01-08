From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is received
Date: Thu, 8 Jan 2015 10:49:10 -0500
Message-ID: <CADVnQy=A57TUYD=kGtZXvq7-FGSN=vN3D2heaNCnBB=zjujwUg@mail.gmail.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
	<1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<54AEA498.5030202@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: =?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:41799 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756027AbbAHPtN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:49:13 -0500
Received: by mail-qg0-f46.google.com with SMTP id q107so2686593qgd.5
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 07:49:11 -0800 (PST)
In-Reply-To: <54AEA498.5030202@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 8, 2015 at 10:39 AM, S=C3=A9bastien Barr=C3=A9
<sebastien.barre@uclouvain.be> wrote:
> What do you and Neal think ?

My preference is to have the whole expression detecting the case where
the receiver got the probe packet encoded in a single expression. I
don't have a strong feeling about whether it should be stored in a
bool (to reduce the size of the diff) or written directly into the if
() expression (to reduce the size of the code). I'll defer to Eric on
which he thinks is better. :-)

neal
