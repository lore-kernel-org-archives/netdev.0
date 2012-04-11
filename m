From: Marc MERLIN <marc@merlins.org>
Subject: Re: 3.2.8/amd64 full interrupt hangs and deadlocks under big network copies (page allocation failure)
Date: Tue, 10 Apr 2012 22:27:33 -0700
Message-ID: <20120411052733.GA17352@merlins.org>
References: <20120409.143710.879746943062854492.davem@davemloft.net> <4F83316F.20504@lwfinger.net> <1333998672.3007.245.camel@edumazet-glaptop> <20120409.153452.1284163346306246866.davem@davemloft.net> <1334030180.13293.98.camel@edumazet-glaptop> <20120410051127.GA32048@merlins.org> <1334038263.2907.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magic.merlins.org ([209.81.13.136]:46422 "EHLO
	mail1.merlins.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619Ab2DKF1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 01:27:38 -0400
Content-Disposition: inline
In-Reply-To: <1334038263.2907.1.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 08:11:03AM +0200, Eric Dumazet wrote:
> Please try following patch, as it solved the problem for me (no more
> order-1 allocations in tx path)

I applied our patch to 3.3.1 and cannot reproduce the problem anymore.

I'll leave a big wireless copy running overnight just in case, but I think
you fixed it.

Thanks much,
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
