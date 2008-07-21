From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH RFC 3/3] net_sched: Add size table for qdiscs
Date: Mon, 21 Jul 2008 16:03:55 +0300
Message-ID: <20080721160355.80675rpj7pj0nf9c@naisho.dyndns.info>
References: <20080717100921.3327.3324.stgit@fate.lan>
	<20080717100938.3327.45121.stgit@fate.lan> <487F1F58.3040701@trash.net>
	<20080717210231.28364m21mg503g8w@hayate.ip6> <48848871.3050900@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:57111 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbYGUND6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 09:03:58 -0400
In-Reply-To: <48848871.3050900@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting "Patrick McHardy" <kaber@trash.net>:

>
> Yes. You check on ->enqueue by using the inner qdiscs size table,
> but that qdisc might again have an inner qdisc which increases
> the size, which you can't check during ->enqueue.
>
>

Ok, I'll send patch when I get back next week.


