From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [net v3] veth: advertise peer link once both links are tied together
Date: Mon, 30 May 2016 18:01:00 +0200
Message-ID: <87bn3n358j.fsf@zoro.exoscale.ch>
References: <574C6095.9050804@6wind.com>
	<1464623917-11536-1-git-send-email-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:40387 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161301AbcE3QBC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 12:01:02 -0400
In-Reply-To: <1464623917-11536-1-git-send-email-vincent@bernat.im> (Vincent
	Bernat's message of "Mon, 30 May 2016 17:58:37 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 30 mai 2016 17:58 CEST, Vincent Bernat <vincent@bernat.im>=C2=
=A0:

> +
> +	rtmsg_ifinfo(RTM_NEWLINK, peer, IFF_SLAVE, GFP_KERNEL);

Maybe ~0U would be better than hijacking IFF_SLAVE?
--=20
Anyone who has had a bull by the tail knows five or six more things
than someone who hasn't.
		-- Mark Twain
