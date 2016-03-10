From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Fri, 11 Mar 2016 00:19:45 +0300
Message-ID: <20160310211945.GD1989@uranus.lan>
References: <20160310200133.GA1989@uranus.lan>
 <20160310.150311.1210460824855467762.davem@davemloft.net>
 <20160310201351.GB1989@uranus.lan>
 <20160310.160521.1642655131932337300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160310.160521.1642655131932337300.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2016 at 04:05:21PM -0500, David Miller wrote:
> > 
> > and nobody calls for nf_ct_iterate_cleanup, no?
> 
> Oh yes they do, from masq's non-inet notifier.  masq registers two
> notifiers, one for generic netdev and one for inetdev.

Thanks a huge David! I'll test it just to be sure.

	Cyrill
