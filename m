From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Question on rhashtable in worst-case scenario.
Date: Thu, 31 Mar 2016 17:22:41 +0200
Message-ID: <1459437761.4576.25.camel@sipsolutions.net>
References: <56F9941A.3080501@candelatech.com>
		 <56FAAA6D.3070806@candelatech.com>
		 <1459329252.2055.1.camel@sipsolutions.net>
		 <20160330.123821.328761526754742195.davem@davemloft.net>
		 <56FC0445.6010200@candelatech.com>
	 <1459410405.4576.8.camel@sipsolutions.net>
	 <56FD3E91.9020804@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	tgraf@suug.ch
To: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:45676 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752260AbcCaPWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2016 11:22:51 -0400
In-Reply-To: <56FD3E91.9020804@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-31 at 08:13 -0700, Ben Greear wrote:
>=C2=A0
> I see insertion failure, and then later, if of course fails to delete
> as well since it was never inserted to begin with.=C2=A0=C2=A0There i=
s no good
> way to deal with insertion error, so just need to fix the hashtable.

Oh, that's an oversight in mac80211 - it should be dealing with
insertion failures properly. This isn't really a problem either,
although it will lead to errors in your particular case.

https://p.sipsolutions.net/cf77c78d69a231d4.txt

johannes
