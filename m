From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169/r8168 slow internet upload
Date: Thu, 15 May 2014 00:03:04 +0200
Message-ID: <20140514220304.GA7520@electric-eye.fr.zoreil.com>
References: <20140511231946.GA12504@offline.be>
 <20140512054447.GA17153@electric-eye.fr.zoreil.com>
 <20140513005023.GA24091@offline.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marc Duponcheel <marc@offline.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48743 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbaENWDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 18:03:08 -0400
Content-Disposition: inline
In-Reply-To: <20140513005023.GA24091@offline.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Duponcheel <marc@offline.be> :
[...]
> not something to do on a router)). That should be fine since r8168
> gave better results.

Is r8169 unusable even at 100 ?

[...]
> * case  100 (when router enp{2,3}s0 are  100Mbps)
> interestingly enough, speed took off at expected 6Mbps but dropped to
> stable 1.5Mbps

I haven't found a clear packet loss pattern yet.

Can you take the *same* (100) capture at enp3s0 ?

If the network speed test is fine as long as the client is near, I'd
seriously question your (c*gent ?) transit.

mtr output from far client to server would be welcome.

-- 
Ueimor
