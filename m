From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire
 X4150(x86) and e1000e
Date: Tue, 29 May 2012 17:11:51 +0200
Message-ID: <1338304311.2840.37.camel@edumazet-glaptop>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	 <88c43001441945e1431609db252b69e7@visp.net.lb>
	 <df211722d18136698aeeda2f17b876e2@visp.net.lb>
	 <d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	 <CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	 <79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	 <CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	 <20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
	 <CA+mtBx_uYy9XcRvpD2E46FuMBFu38iQvCiwFHWqbhPBmY=JfOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	davem@davemloft.net
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36761 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860Ab2E2PL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 11:11:57 -0400
Received: by eeit10 with SMTP id t10so1146245eei.19
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 08:11:56 -0700 (PDT)
In-Reply-To: <CA+mtBx_uYy9XcRvpD2E46FuMBFu38iQvCiwFHWqbhPBmY=JfOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-29 at 07:54 -0700, Tom Herbert wrote:
> Thanks Hiroaki for this description, it looks promising.  Denys, can
> you test with his patch.
> 
> Tom

Indeed this sounds good.

Hmm, I guess my e1000e has no FLAG2_DMA_BURST in adapter->flags2
