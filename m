From: "Adrian McMenamin" <lkmladrian@gmail.com>
Subject: Re: [PATCH] Fix broken ip= parsing
Date: Sat, 29 Dec 2007 22:54:22 +0000
Message-ID: <8b67d60712291454y6c60151cm7d9a4957e35adbfd@mail.gmail.com>
References: <20071229170849.C2E68C2EEE@solo.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	horms@verge.net.au, davem@davemloft.net
To: "Thomas Bogendoerfer" <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:62322 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380AbXL2WyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 17:54:23 -0500
Received: by py-out-1112.google.com with SMTP id u52so8377531pyb.10
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2007 14:54:22 -0800 (PST)
In-Reply-To: <20071229170849.C2E68C2EEE@solo.franken.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/12/2007, Thomas Bogendoerfer <tsbogend@alpha.franken.de> wrote:
> Commit a6c05c3d064dbb83be88cba3189beb5db9d2dfc3 breaks ip= parsing
> completly, because ic_enable is never set. The patch below puts
> back the way ic_enable was set before.
>
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> ---
>
This patch certainly fixes the problem I was having with NFS root - I
had a working setup that stopped (though at the same time as I updated
my Busybox setup so I thought this was my mistake).

Please apply.

Tested by: Adrian McMenamin <adrian@mcmen.demon.co.uk>
