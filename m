From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: vlan: inherit addr_assign_type along with dev_addr
Date: Fri, 23 Aug 2013 11:11:40 +0200
Message-ID: <8738q04vqr.fsf@nemi.mork.no>
References: <1377174201-20236-1-git-send-email-bjorn@mork.no>
	<20130822.114920.610022099919624531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40412 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754930Ab3HWJME convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 05:12:04 -0400
In-Reply-To: <20130822.114920.610022099919624531.davem@davemloft.net> (David
	Miller's message of "Thu, 22 Aug 2013 11:49:20 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> Date: Thu, 22 Aug 2013 14:23:21 +0200
>
>> A vlan device inheriting a random or set address should reflect
>> this in its addr_assign_type.
>>=20
>> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
>
> I think this might deserve a helper function, I'd not be surprised
> if we do MAC address propagation like this in other situations and
> they have the same bug.

Yes.  Grepping a bit shows that there area few more candidates. Althoug=
h
some of these could probably set addr_assign_type to NET_ADDR_STOLEN
(like the bonding driver does) instead.  Maybe that should depend on th=
e
addr_assign_type of the source device?

Never mind. I don't know what this should look like. I'll prepare a
patch set with a helper, and propose changes to all the candidate
drivers I can find, leaving it up to the maintainers to object if they
don't like it.


Bj=C3=B8rn
