From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 17:40:45 +0300
Message-ID: <5695106D.8040909@list.ru>
References: <5682665A.7090102@list.ru> <20151229152208.GA22423@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8.mail.ru ([94.100.181.96]:49042 "EHLO smtp8.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762505AbcALOkt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2016 09:40:49 -0500
In-Reply-To: <20151229152208.GA22423@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

29.12.2015 18:22, Sowmini Varadhan =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>=20
> Do you have admin control over the ubuntu router?
> If yes, you might want to check the shared_media [#] setting=20
> on that router for the interfaces with overlapping subnets.
> (it is on by default, I would try turning it off).
Updated testing results:
After I disabled shared_media not only for "all", but
also for _all_ interfaces individually, the problem seem to
have stopped. So thanks for these hints.
Now, as the media is actually really shared (same NIC/cable),
I just wonder what's going on here.

And unfortunately we still don't know why these redirects are
ever accepted...
