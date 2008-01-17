From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Wed, 16 Jan 2008 20:25:57 -0500
Message-ID: <1200533157.4451.86.camel@localhost>
References: <478A038B.4090900@iki.fi> <1200491531.4457.91.camel@localhost>
	 <478E1479.3020204@iki.fi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:46377 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbYAQB0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 20:26:01 -0500
Received: by py-out-1112.google.com with SMTP id u52so676095pyb.10
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 17:26:00 -0800 (PST)
In-Reply-To: <478E1479.3020204@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-16-01 at 16:28 +0200, Timo Ter=E4s wrote:
[..]
> Creating a separate af_key patch would not be a big problem. I was
> just hoping avoiding it as the xfrm_state / xfrm_policy changes
> modify the API and requires changing af_key also.

The way dumping is done by xfrm_user is consistent across all netlink
not just ipsec. Thats why i said it had broader implications.=20
OTOH, theres a clear issue with pf_key.

> No. I'm not creating second copies of the SADB/SPD entries. The entri=
es
> are just added to one more list.

Ah, sorry - yes, that sounds reasonable.
So what happens if i delete an entry; does it get removed from the list=
?
Also what happens on modification?

> If more entries are added, you can get notifications of them.

how would a user app (example racoon) appropriately deal with it?
Example an entry sits in the dump-list, it gets deleted - an event gets
generated user-space and later that entry shows up in user space dump.

cheers,
jamal

