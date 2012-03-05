From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net] mlx4_core: remove buggy sched_queue masking
Date: Mon, 5 Mar 2012 22:52:01 +0200
Message-ID: <CAJZOPZL+7CWKBOnN4zNZ7C+8kMNwR7yT1EYm6xz_BvCTd+E=pw@mail.gmail.com>
References: <4F54D3C1.8000902@mellanox.co.il>
	<CAL1RGDWAHNRK5paWzE1xKPCxgKMEQi65_ZD7p1Nk+TGNXsQ9aA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>, davem@davemloft.net,
	netdev@vger.kernel.org, amirv@mellanox.co.il
To: Roland Dreier <roland@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:33897 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757696Ab2CEUwC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 15:52:02 -0500
Received: by lahj13 with SMTP id j13so5104321lah.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 12:52:01 -0800 (PST)
In-Reply-To: <CAL1RGDWAHNRK5paWzE1xKPCxgKMEQi65_ZD7p1Nk+TGNXsQ9aA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier <roland@purestorage.com> wrote:

>> =A0 =A0 =A0 =A0port =3D ((context->pri_path.sched_queue >> 6) & 1) +=
 1;

> This assignment of port seems to become dead code now...

good catch, yep, we will do this little cleanup and repost tomorrow,
however to make things clear, the point here was fixing that
regression.

Or.
