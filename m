From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: Neighbor Discovery from non-neighbors (fwd)
Date: Thu, 02 Oct 2008 13:12:46 +0200
Message-ID: <b2e1b9b8d654209df21d724dd7a15182@chewa.net>
References: <alpine.LRH.2.00.0810021048040.11598@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:50569 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751949AbYJBLMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 07:12:49 -0400
In-Reply-To: <alpine.LRH.2.00.0810021048040.11598@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2 Oct 2008 11:07:48 +0300 (EEST), Pekka Savola <pekkas@netcore.=
fi>=0D
wrote:=0D
> There is a bug in the Neighbor Discovery spec, and it's possible that=
=0D
> Linux would also be similarly affected.  Anyone check?=0D
=0D
The NA receiving code does not appear to check for "on-link"ness of the=
=0D
target, so it seems polluting the neighbors cache is do-able. However, =
it=0D
is not clear to me whether this can override IPv6 routing. I wish=0D
Yoshifuji-san were around.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont

