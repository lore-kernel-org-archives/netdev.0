From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 10:45:59 +0000
Message-ID: <20090518104559.GA11162@ff.dom.local>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com> <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com> <20090515111227.7fc758cd@nehalam> <298f5c050905180301s1c4ffdb2p61a155668eb39bd2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:29121 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753278AbZERKqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 06:46:11 -0400
Received: by yx-out-2324.google.com with SMTP id 3so1921524yxj.1
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 03:46:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <298f5c050905180301s1c4ffdb2p61a155668eb39bd2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2009 at 11:01:21AM +0100, Antonio Almeida wrote:
> Hi!
> 
> cat /sys/devices/system/clocksource/clocksource0/current_clocksource
> returns "jiffies"
> 
> With HFSC the accuracy is good. Also with packets of 800 bytes I got
> these values:
> received            configured         error
> 904596519	900000000		0,51
> 804293658	800000000		0,54
> 703662853	700000000		0,52
> 603354059	600000000		0,56
> 502805411	500000000		0,56
> 402527055	400000000		0,63
> 301484904	300000000		0,49
> 201074301	200000000		0,54
> 100546656	100000000		0,55
> 

Looks great! But, since HFSC uses rates directly (without rate tables)
seems to be logical. So, it looks like the best choice for handling
>100Mbit configs now.

Thanks,
Jarek P.
