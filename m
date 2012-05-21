From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire
 X4150(x86) and e1000e
Date: Mon, 21 May 2012 10:30:05 +0200
Message-ID: <1337589005.3361.19.camel@edumazet-glaptop>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	 <88c43001441945e1431609db252b69e7@visp.net.lb>
	 <df211722d18136698aeeda2f17b876e2@visp.net.lb>
	 <d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	 <CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	 <79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	 <CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	 <4775d023592b876909aceb152f94aa01@visp.net.lb>
	 <1337540825.3361.0.camel@edumazet-glaptop>
	 <ef780bd0e0b9b9e60e37fa74101f0f66@visp.net.lb>
	 <1337572583.3361.8.camel@edumazet-glaptop>
	 <6d7500e1c3b4b191c0b5a11003b161d6@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, davem@davemloft.net
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:64899 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755719Ab2EUIaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 04:30:11 -0400
Received: by eeit10 with SMTP id t10so1306819eei.19
        for <netdev@vger.kernel.org>; Mon, 21 May 2012 01:30:09 -0700 (PDT)
In-Reply-To: <6d7500e1c3b4b191c0b5a11003b161d6@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-21 at 11:06 +0300, Denys Fedoryshchenko wrote:

> Not sure it is a lot of time, after all it is 2 x core quad machine, 
> should be enough fast for pings.
> It will cause stalls on small packets even more seems.
> 
> Tested latest git, net-next, still the same, stalls.
> hardware latency detector are silent by the way, so there is no 
> significant SMI.
> 

I am trying to reproduce your problem here with no luck yet.

I wonder of softirq are correctly scheduled on your machine
