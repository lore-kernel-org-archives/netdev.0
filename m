From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Thu, 21 Mar 2013 17:25:23 -0400 (EDT)
Message-ID: <20130321.172523.1037964587501349728.davem@davemloft.net>
References: <CAHo-OowoWD_BT2W8ok32pcSmcshXttpErna-X92Ojz_A8es8iw@mail.gmail.com>
	<CAHo-Ooz2W_jcbbOFLvihf+N-6fVSNoj0jGKTT8AXoOSC3_3DRg@mail.gmail.com>
	<CAHo-Oow3D1haZ8MzV7B0boc-fzL-S7DT+6QuOEgQCSYcvenXsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eilong@broadcom.com, eric.dumazet@gmail.com, dmitry@broadcom.com,
	netdev@vger.kernel.org, yuvalmin@broadcom.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab3CUVZZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 17:25:25 -0400
In-Reply-To: <CAHo-Oow3D1haZ8MzV7B0boc-fzL-S7DT+6QuOEgQCSYcvenXsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Thu, 21 Mar 2013 14:23:47 -0700

> (a) The DIFF_64 macro is buggy in the case of underflow due to unsign=
ed-ness
> (b) Any code which does SUB/ADD should instead do ADD/SUB, because
> SUB(A,B) is implemented via DIFF(A,B) and thus doesn't actually do
> subtraction, but instead does A :=3D max(A-B, 0)
> (c) there's a bunch of extra statistics it is trivial to export via
> ethtool which make debugging stuff like this much easier

Thanks for looking into this and the status update.
