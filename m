From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [PATCH] rc80211_pid: Fix fast_start parameter handling
Date: Mon, 7 Jul 2008 22:31:58 +0200
Message-ID: <19f34abd0807071331s52dc994ao6ac70e787d88227d@mail.gmail.com>
References: <19f34abd0807070427w5398c617uae0a4e8e40fd8f0e@mail.gmail.com>
	 <1215462228.4416.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Stefano Brivio" <stefano.brivio@polimi.it>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Ingo Molnar" <mingo@elte.hu>,
	"Pekka Enberg" <penberg@cs.helsinki.fi>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Mattias Nissler" <mattias.nissler@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:38641 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757704AbYGGUcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 16:32:00 -0400
Received: by yx-out-2324.google.com with SMTP id 8so509138yxm.1
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2008 13:31:59 -0700 (PDT)
In-Reply-To: <1215462228.4416.3.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Jul 7, 2008 at 10:23 PM, Mattias Nissler <mattias.nissler@gmx.de> wrote:
> This removes the fast_start parameter from the rc_pid parameters information
> and instead uses the parameter macro when initializing the rc_pid state. Since the
> parameter is only used on initialization, there is no point of making exporting
> it via debugfs. This also fixes uninitialized memory references to the
> fast_start and norm_offset parameters.
>
> Signed-off-by: Mattias Nissler <mattias.nissler@gmx.de>
> ---
>
> This should fix the problem. I think this should go into mainline ASAP.

Was this code actually causing some problem/regression? If so, can we
please have a reference to bugzilla/prior conversations in the patch
description?

Was the reason for the problem known before I posted the "use of
uninitialized memory" e-mail earlier today? If no, can you please
sneak in a little reference to kmemcheck there in the patch
description? The acknowledgement is sorely needed :-)

Thanks!


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
