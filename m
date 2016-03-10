From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Thu, 10 Mar 2016 23:19:13 +0300
Message-ID: <20160310201913.GC1989@uranus.lan>
References: <CAM_iQpWWbj00H-cKvpeaKq6mVWK_D2CFuarXiE6YDQeQX5JupA@mail.gmail.com>
 <20160310.145543.990436948715023108.davem@davemloft.net>
 <20160310200133.GA1989@uranus.lan>
 <20160310.150311.1210460824855467762.davem@davemloft.net>
 <20160310201351.GB1989@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160310201351.GB1989@uranus.lan>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2016 at 11:13:51PM +0300, Cyrill Gorcunov wrote:
> > 
> > Both notifiers are run in the inetdev_destroy() case.
> > 
> > Maybe that's what you are missing.
> 
> No :) Look, here is what I mean. Previously with your two patches
> we've been calling nf-cleanup for every address, so we had to make
> code call for cleanup for one time only. Now with the patch above
> the code flow is the following

Ah, I'm idiot, drop the question.
