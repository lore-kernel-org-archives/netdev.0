From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is received
Date: Thu, 8 Jan 2015 10:52:28 -0500
Message-ID: <CADVnQyk-Vq3M=vwv77dcXws_Hc1AvzQgDb6UD5bWL=ohowgdbA@mail.gmail.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
	<1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<54AEA498.5030202@uclouvain.be>
	<CADVnQy=A57TUYD=kGtZXvq7-FGSN=vN3D2heaNCnBB=zjujwUg@mail.gmail.com>
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
Received: from mail-qc0-f172.google.com ([209.85.216.172]:44779 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbbAHPw3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:52:29 -0500
Received: by mail-qc0-f172.google.com with SMTP id m20so2522421qcx.3
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 07:52:28 -0800 (PST)
In-Reply-To: <CADVnQy=A57TUYD=kGtZXvq7-FGSN=vN3D2heaNCnBB=zjujwUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 8, 2015 at 10:49 AM, Neal Cardwell <ncardwell@google.com> w=
rote:
> On Thu, Jan 8, 2015 at 10:39 AM, S=C3=A9bastien Barr=C3=A9
> <sebastien.barre@uclouvain.be> wrote:
>> What do you and Neal think ?
>
> My preference is to have the whole expression detecting the case wher=
e
> the receiver got the probe packet encoded in a single expression.

If we do store it in a bool, then "is_tlp_dupack" is no longer quite
accurate (we're expanding the check to include ACKs that are not
dupacks), so I'd suggest a name like "is_probe_rcvd".

neal
