From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC/PATCH 4/4] UDP memory usage accounting (take 4): memory
 limitation
Date: Thu, 11 Oct 2007 12:46:56 -0700
Message-ID: <20071011124656.01dd575b@freepuppy.rosehill>
References: <47065139.5030402@hitachi.com>
	<47065217.5050004@hitachi.com>
	<20071005085257.24b2e5cc@freepuppy.rosehill>
	<470E1C42.1050901@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>, ?? ?? <yoshfuji@linux-ipv6.org>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	"??@RedHat" <haoki@redhat.com>
To: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55028 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753562AbXJKTuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 15:50:22 -0400
In-Reply-To: <470E1C42.1050901@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Oct 2007 21:51:14 +0900
Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com> wrote:

> Hi Stephen,
> 
> Thank you for your comment.
> 
> >>  	{
> >> +		.ctl_name	= NET_UDP_MEM,
> >> +		.procname	= "udp_mem",
> >> +		.data		= &sysctl_udp_mem,
> >> +		.maxlen		= sizeof(sysctl_udp_mem),
> >> +		.mode		= 0644,
> >> +		.proc_handler	= &proc_dointvec
> >> +	},
> >> +	{
> >>  		.ctl_name	= NET_TCP_APP_WIN,
> >>  		.procname	= "tcp_app_win",
> >>  		.data		= &sysctl_tcp_app_win,
> > 
> > if you use &proc_dointvec_minmax, then you could inforce min/max
> > values for udp_mem for the sysctl

One other comment. Sysctl value indexes are deprecated at this point
so all new values should use CTL_UNNUMBERED.  Therefore unless NET_UDP_MEM
already exists, please don't add it.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
