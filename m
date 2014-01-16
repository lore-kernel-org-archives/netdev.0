From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH V2 net-next 1/3] ipv6: add the IPV6_FL_F_REFLECT flag
 to IPV6_FL_A_GET
Date: Thu, 16 Jan 2014 15:34:56 +0100
Message-ID: <52D7EE10.6010306@enst-bretagne.fr>
References: <1389785403-6401-1-git-send-email-florent.fourcot@enst-bretagne.fr> <20140115224726.GH19945@order.stressinduktion.org> <20140116123515.GD7436@order.stressinduktion.org> <52D7D45E.6000908@enst-bretagne.fr> <20140116130753.GE7436@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:56851 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751435AbaAPOe7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 09:34:59 -0500
In-Reply-To: <20140116130753.GE7436@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/01/2014 14:07, Hannes Frederic Sowa a =C3=A9crit :
> Would it make sense to sync the flowlabel if it changes with the sock=
et, so
> user space can query the label really used? Otherwise I wouldn't even=
 report
> it.

I see at least one use case. In the same way that openssh sets the
tclass field after the SSH session initialization, a software could set
the label after the beginning of the L7 session (and ignoring QoS
priority for non-interactive packet at the beginning).
