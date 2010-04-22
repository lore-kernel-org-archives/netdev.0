From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] TCP: avoid to send keepalive probes if it is
 receiving data
Date: Wed, 21 Apr 2010 22:42:05 -0700 (PDT)
Message-ID: <20100421.224205.18551946.davem@davemloft.net>
References: <1271602519-6805-1-git-send-email-fleitner@redhat.com>
	<1271610919.16881.5564.camel@edumazet-laptop>
	<alpine.DEB.2.00.1004182328370.19304@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, fleitner@redhat.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59024
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751621Ab0DVFmA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 01:42:00 -0400
In-Reply-To: <alpine.DEB.2.00.1004182328370.19304@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sun, 18 Apr 2010 23:34:15 +0300 (EEST)

> I fail to see why the addition of this new variable is necessary at a=
ll,=20
> could either of you enlight me why exactly it's necessary and rcv_tst=
amp=20
> will not suffice?

I agree, the existing rcv_tstamp should serve this purpose just
fine.
