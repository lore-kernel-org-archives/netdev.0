From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: switch rtt estimations to usec
 resolution
Date: Sun, 23 Feb 2014 13:41:58 -0800
Message-ID: <1393191718.2316.57.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	 <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAK6E8=e=vm=V+in0UO5mJxfwp6ivpmARhFFoC0oS59iYbZ4L5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:57534 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbaBWVmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 16:42:00 -0500
Received: by mail-pa0-f50.google.com with SMTP id kp14so5646067pab.23
        for <netdev@vger.kernel.org>; Sun, 23 Feb 2014 13:41:59 -0800 (PST)
In-Reply-To: <CAK6E8=e=vm=V+in0UO5mJxfwp6ivpmARhFFoC0oS59iYbZ4L5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-02-23 at 11:19 -0800, Yuchung Cheng wrote:

> Let's change sack RTT to usec as well so the srtt estimator takes RTT
> using the same precision.
> 
> I've sketched a patch (compile test only), and will review your patch
> more thoroughly tomorrow. Thanks!
> 

Thanks, I'll integrate this in v3.
