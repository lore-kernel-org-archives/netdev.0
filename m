From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/1] TCP: increase default initial receive window.
Date: Tue, 21 Dec 2010 06:00:06 +0100
Message-ID: <1292907606.2627.151.camel@edumazet-laptop>
References: <1292642451-892-1-git-send-email-nanditad@google.com>
	 <1292890556-29904-1-git-send-email-nanditad@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35236 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773Ab0LUFAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 00:00:12 -0500
Received: by wwa36 with SMTP id 36so3754624wwa.1
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 21:00:11 -0800 (PST)
In-Reply-To: <1292890556-29904-1-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 d=C3=A9cembre 2010 =C3=A0 16:15 -0800, Nandita Dukkipati a =
=C3=A9crit :
> This patch changes the default initial receive window to 10 mss
> (defined constant). The default window is limited to the maximum
> of 10*1460 and 2*mss (when mss > 1460).
>=20
> draft-ietf-tcpm-initcwnd-00 is a proposal to the IETF that recommends
> increasing TCP's initial congestion window to 10 mss or about 15KB.
> Leading up to this proposal were several large-scale live Internet
> experiments with an initial congestion window of 10 mss (IW10), where
> we showed that the average latency of HTTP responses improved by
> approximately 10%. This was accompanied by a slight increase in
> retransmission rate (0.5%), most of which is coming from applications
> opening multiple simultaneous connections. To understand the extreme
> worst case scenarios, and fairness issues (IW10 versus IW3), we furth=
er
> conducted controlled testbed experiments. We came away finding minima=
l
> negative impact even under low link bandwidths (dial-ups) and small
> buffers.  These results are extremely encouraging to adopting IW10.
>=20
> However, an initial congestion window of 10 mss is useless unless a T=
CP
> receiver advertises an initial receive window of at least 10 mss.
> Fortunately, in the large-scale Internet experiments we found that mo=
st
> widely used operating systems advertised large initial receive window=
s
> of 64KB, allowing us to experiment with a wide range of initial
> congestion windows. Linux systems were among the few exceptions that
> advertised a small receive window of 6KB. The purpose of this patch i=
s
> to fix this shortcoming.
>=20
> References:
> 1. A comprehensive list of all IW10 references to date.
> http://code.google.com/speed/protocols/tcpm-IW10.html
>=20
> 2. Paper describing results from large-scale Internet experiments wit=
h IW10.
> http://ccr.sigcomm.org/drupal/?q=3Dnode/621
>=20
> 3. Controlled testbed experiments under worst case scenarios and a
> fairness study.
> http://www.ietf.org/proceedings/79/slides/tcpm-0.pdf
>=20
> 4. Raw test data from testbed experiments (Linux senders/receivers)
> with initial congestion and receive windows of both 10 mss.
> http://research.csc.ncsu.edu/netsrv/?q=3Dcontent/iw10
>=20
> 5. Internet-Draft. Increasing TCP's Initial Window.
> https://datatracker.ietf.org/doc/draft-ietf-tcpm-initcwnd/
>=20
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


