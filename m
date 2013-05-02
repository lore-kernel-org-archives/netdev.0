From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v7 4/6] vxlan: add ipv6 support
Date: Thu, 02 May 2013 16:05:53 +0800
Message-ID: <1367481953.2415.29.camel@cr0>
References: <1367311395-15891-1-git-send-email-amwang@redhat.com>
	 <1367311395-15891-5-git-send-email-amwang@redhat.com>
	 <87r4hscr7s.fsf@nemi.mork.no> <1367313956.3216.18.camel@cr0>
	 <87mwsgcnoy.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750910Ab3EBIGR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 May 2013 04:06:17 -0400
In-Reply-To: <87mwsgcnoy.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-30 at 12:33 +0200, Bj=C3=B8rn Mork wrote:
>=20
> Well, you have been told that your proposed new feature breaks IPv4
> support with specific settings.  I do not think that you are speeding
> up
> anything here by ignoring that fact.  On the contrary.=20

It is obviously a corner case which is not deserved such a high priorit=
y
(as high as a kernel panic or a compile error). bindv6only is default t=
o
be 0, I even wasn't aware of such sysctl until David pointed it out.

So, please give me a reason why we should let such a corner case block
the inclusion? I think there are still other such corner cases too (and
maybe many), which neither you nor me are aware of.
