From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v7 net-next 2/2] tcp: switch rtt estimations to usec resolution
Date: Wed, 26 Feb 2014 17:21:25 -0800
Message-ID: <530E9315.5080606@hp.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com> <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg> <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com> <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com> <1393216927.2316.62.camel@edumazet-glaptop2.roam.corp.google.com> <1393266251.2316.68.camel@edumazet-glaptop2.roam.corp.google.com> <alpine.LFD.2.11.1402242240290.1941@ja.home.ssi.bg> <1393280025.2316.76.camel@edumazet-glaptop2.roam.corp.google.com> <alpine.LFD.2.11.1402250056250.1941@ja.home.ssi.bg> <1393284682.2316.83.camel@edumazet-glaptop2.roam.corp.google.com> <20140224155130.4c286cca@samsung-9> <1393290667.2316.96.camel@edumazet-glaptop2.roam.corp.google.com> <1393292339.2316.98.camel@edumazet-glaptop2.roam.corp.google.com> <1
 393309341.2316.120.camel@edumazet-glaptop2.roam.corp.google.com> <1393452168.26794.8.camel@edumazet-glaptop2.roam.corp.google.com> <20140226170908.5f028c88@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Julian Anastasov <ja@ssi.bg>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:60365 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116AbaB0BWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 20:22:05 -0500
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com [15.201.208.53])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hp.com (Postfix) with ESMTPS id F334E618E4
	for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 01:22:03 +0000 (UTC)
In-Reply-To: <20140226170908.5f028c88@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2014 05:09 PM, Stephen Hemminger wrote:
> Since srtt is scaled by 8 and is 32 bits, This does reduce the maximum
> possible RTT to 8 minutes or so. Which is fine, just wanted it to be
> noted.

I have encountered some situations recently, admittedly very 
pathological, where the RTT through a VPN connection was measured in 
minutes.  I don't think it got as high as 8 minutes, but it did get as 
high as three or so.  Also mentioned only for the record.

rick jones
