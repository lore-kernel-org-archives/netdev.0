From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 1/4] ipv4: add option to drop unicast encapsulated in
 L2 multicast
Date: Thu, 5 Nov 2015 10:25:01 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1511051017220.1651@ja.home.ssi.bg>
References: <1446654127-26826-1-git-send-email-johannes@sipsolutions.net>  <alpine.LFD.2.11.1511042215570.2194@ja.home.ssi.bg> <1446672958.13649.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1750584350-1446711901=:1651"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:38864 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030939AbbKEI0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2015 03:26:55 -0500
In-Reply-To: <1446672958.13649.4.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1750584350-1446711901=:1651
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Wed, 4 Nov 2015, Johannes Berg wrote:

> On Wed, 2015-11-04 at 22:59 +0200, Julian Anastasov wrote:
> > 
> >         } else if (unlikely(skb->pkt_type != PACKET_HOST)) {
> > 
> >         May be such check can save some cycles because
> > it is more common to see PACKET_HOST packets...
> 
> I had thought about that based on your earlier comments, but then I
> didn't quite see the point. However, perhaps we could invert the check
> below to check the pkt_type first, hoping it'll have some kind of cache
> effect?

	Yes, looks like it would be better if the checks
are reordered, the IN_DEV_* methods look more complex recently.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1750584350-1446711901=:1651--
