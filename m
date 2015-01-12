From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next v3] tcp: avoid reducing cwnd when ACK+DSACK is received
Date: Mon, 12 Jan 2015 11:48:20 -0500
Message-ID: <CADVnQy=JDAoLtBnFXsQDTU1_OYFGpDCF1Un28iM1gz0KZDGoug@mail.gmail.com>
References: <1421055040-8732-1-git-send-email-sebastien.barre@uclouvain.be>
	<1421075729.4099.0.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>,
	David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:64553 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbbALQs3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 11:48:29 -0500
Received: by mail-qa0-f43.google.com with SMTP id v10so11121678qac.2
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 08:48:28 -0800 (PST)
In-Reply-To: <1421075729.4099.0.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-01-12 at 10:30 +0100, S=C3=A9bastien Barr=C3=A9 wrote:
> With TLP, the peer may reply to a probe with an
> ACK+D-SACK, with ack value set to tlp_high_seq. In the current code,
> such ACK+DSACK will be missed and only at next, higher ack will the T=
LP
> episode be considered done. Since the DSACK is not present anymore,
> this will cost a cwnd reduction.

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks!
neal
