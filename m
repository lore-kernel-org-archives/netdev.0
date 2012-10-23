From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 06/15] 6lowpan: fix first fragment (FRAG1)
 handling
Date: Tue, 23 Oct 2012 17:03:30 +0200
Message-ID: <1351004610.8609.2068.camel@edumazet-glaptop>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org>
	 <1350965397-12384-7-git-send-email-tony.cheneau@amnesiak.org>
	 <5086450A.9050506@computer.org>
	 <1bf85bdd4343fe738d15ee74a65578d5@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Ceuleers <jan.ceuleers@computer.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	Alan Ott <alan@signal11.us>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56828 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932291Ab2JWPDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 11:03:34 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1627636bkc.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 08:03:33 -0700 (PDT)
In-Reply-To: <1bf85bdd4343fe738d15ee74a65578d5@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-23 at 16:50 +0200, Tony Cheneau wrote:

> >
> > +	hlen = (type == LOWPAN_DISPATCH_FRAG1 ? LOWPAN_FRAG1_HEAD_SIZE :
> > +		LOWPAN_FRAGN_HEAD_SIZE);
> >
> > So the L for LOWPAN_FRAGN_HEAD_SIZE should be underneath the t for 
> > type.
> Will do as well.

By the way parens are not needed, or better like that :

	hlen = (type == LOWPAN_DISPATCH_FRAG1) ?
			LOWPAN_FRAG1_HEAD_SIZE : LOWPAN_FRAGN_HEAD_SIZE;
