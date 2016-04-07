From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] net: mark DECnet as broken
Date: Thu, 7 Apr 2016 15:01:20 +0100
Message-ID: <20160407150120.22934228@lxorguk.ukuu.org.uk>
References: <1460013763-22985-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:36268 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755633AbcDGOBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 10:01:36 -0400
In-Reply-To: <1460013763-22985-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  7 Apr 2016 09:22:43 +0200
Vegard Nossum <vegard.nossum@oracle.com> wrote:

> There are NULL pointer dereference bugs in DECnet which can be triggered
> by unprivileged users and have been reported multiple times to LKML,
> however nobody seems confident enough in the proposed fixes to merge them
> and the consensus seems to be that nobody cares enough about DECnet to
> see it fixed anyway.
> 
> To shield unsuspecting users from the possible DOS, we should mark this
> BROKEN until somebody who actually uses this code can fix it.

How about consigning it to staging at this point ?

Alan
