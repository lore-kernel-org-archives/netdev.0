From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Wed, 03 Sep 2014 10:59:14 +0900
Message-ID: <540675F2.1030308@miraclelinux.com>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>	 (sfid-20140821_192515_304437_37E734D5) <1408642331.4388.2.camel@jlt4.sipsolutions.net>	 <1409125114.11976.14.camel@localhost>	 <1409130313.2505.3.camel@jlt4.sipsolutions.net>	 <1409133238.26515.13.camel@localhost> <1409650573.1808.11.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Johannes Berg <johannes@sipsolutions.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og112.obsmtp.com ([64.18.2.177]:42680 "HELO
	exprod7og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753271AbaICB7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 21:59:18 -0400
Received: by mail-pa0-f41.google.com with SMTP id lj1so16359864pab.0
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 18:59:17 -0700 (PDT)
In-Reply-To: <1409650573.1808.11.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> As long as IPv6 doesn't mandate it in the RFCs I'm not really sure we
> should just drop it, even if we think it won't cause any problems?
>
> CLUSTERIP seems like a special configuration, but I'm not sure it can be
> detected and automatically allowed?

Please do not "drop" L2 multicast/broadcast for L3 unicast and
vice versa, unless it is explicitly specified by RFC.

Upper-layer needs to cope eith situation of seeing packets with
"incorrect" L2 header anyway (e.g., in promiscous mode).
I do not see much advantage to drop them here.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
