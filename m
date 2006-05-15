From: Meelis Roos <mroos@linux.ee>
Subject: Re: ipv6 routing broken in 2.6.17-rc3,4
Date: Mon, 15 May 2006 20:30:58 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605152029200.9077@math.ut.ee>
References: <Pine.SOC.4.61.0605150909510.29527@math.ut.ee>
 <Pine.LNX.4.64.0605151904110.12081@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:22664 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1751576AbWEORbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 13:31:02 -0400
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.64.0605151904110.12081@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> vaarikas:~# ip -6 route
>> 2002:5283:297e::/48 dev tun6to4  metric 256  expires 21332659sec mtu 1480 
>> advmss 1420 hoplimit 4294967295
>
> You're using the wrong prefix length.  The right one is /16.  Does that work?

Will try soon today. But the other routes had mor specific masks anyway -
/64 and /128, so why should it change anything?

-- 
Meelis Roos (mroos@linux.ee)
