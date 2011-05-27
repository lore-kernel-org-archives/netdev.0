From: Arun Sharma <asharma@fb.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Thu, 26 May 2011 17:09:41 -0700
Message-ID: <4DDEEBC5.80804@fb.com>
References: <201104250033.03401.maxi@daemonizer.de>	 <1303878240.2699.41.camel@edumazet-laptop>	 <1303878771.2699.44.camel@edumazet-laptop>	 <201104271352.00601.maxi@daemonizer.de>	 <20110512211033.GA3468@dev1756.snc6.facebook.com>	 <1305234953.2831.2.camel@edumazet-laptop>	 <20110524213327.GA3917@dev1756.snc6.facebook.com>	 <1306291469.3305.11.camel@edumazet-laptop>	 <20110525060609.GA32244@dev1756.snc6.facebook.com>	 <1306305331.3305.22.camel@edumazet-laptop>  <4DDEAA3C.7020502@fb.com>	 <1306439246.2543.10.camel@edumazet-laptop>  <4DDECA9B.8080206@fb.com> <1306447292.2543.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outmail020.snc4.facebook.com ([66.220.144.152]:49646 "EHLO
	mx-out.facebook.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756405Ab1E0AJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 20:09:20 -0400
In-Reply-To: <1306447292.2543.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/26/11 3:01 PM, Eric Dumazet wrote:


>> Yeah - using the refcnt seems better than list_empty(), but I'm not sure
>> that your patch addresses the race above.
>
> It does.

True. I can't find any holes in this method and it resolves the "failure 
to unlink from unused" case.

Perhaps wrap the while(1) loop into its own primitive in atomic.h or use 
an existing primitive?

  -Arun

