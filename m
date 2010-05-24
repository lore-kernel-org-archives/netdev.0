From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [patch] caif: remove unneeded null check in caif_connect()
Date: Mon, 24 May 2010 21:56:01 +0200
Message-ID: <AANLkTikM6_-YgLcBtcxN_TA1ISHkRk6fCEJVOS7pRZel__9984.64507652006$1274730998$gmane$org@mail.gmail.com>
References: <20100522204342.GV22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Dan Carpenter <error27@gmail.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vge
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36378 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755759Ab0EXT4E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 15:56:04 -0400
In-Reply-To: <20100522204342.GV22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter <error27@gmail.com> wrote:
> We already dereferenced uaddr towards the start of the function when =
we
> checked that "uaddr->sa_family !=3D AF_CAIF". =C2=A0Both the check he=
re and the
> earlier check were added in bece7b2398d0: "caif: Rewritten socket
> implementation". =C2=A0Before that patch, we assumed that we recieved=
 a valid
> pointer for uaddr, and based on that, I have removed this check.
>
> Signed-off-by: Dan Carpenter <error27@gmail.com>
Thanks Looks good,
Acked-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
