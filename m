From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Wed, 9 Mar 2016 19:51:28 +0300
Message-ID: <20160309165128.GK2207@uranus.lan>
References: <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
 <20160304.231109.1838919633640757059.davem@davemloft.net>
 <20160306100932.GP4184@uranus.lan>
 <1457281392.2663.5.camel@edumazet-ThinkPad-T530>
 <20160306170641.GA8820@uranus.lan>
 <20160309163919.GJ2207@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:33756 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598AbcCIQvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 11:51:53 -0500
Received: by mail-lb0-f174.google.com with SMTP id k15so75028433lbg.0
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 08:51:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160309163919.GJ2207@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 09, 2016 at 07:39:19PM +0300, Cyrill Gorcunov wrote:
> On Sun, Mar 06, 2016 at 08:06:41PM +0300, Cyrill Gorcunov wrote:
> > > 
> > > Well, this looks like LOCKDEP kernel. Are you really running LOCKDEP on
> > > production kernels ?
> > 
> 
> Hi Eric, David. Sorry for the delay. Finally I've measured the
> latency on the hw. It's i7-2600 cpu with 16G of memory. Here
> are the collected data.
...
> 
> 
> Also here is a graph for the data collected (blue line: unpatched
> version, red -- patched. Of course with patched version it become
> a way more better but still hanging).
> 
> https://docs.google.com/spreadsheets/d/1eyQDxjuZY2DHKYksGACpHDDcV1Bd92e-ZiY8ywPKshA/edit?usp=sharing
> 
> The perf output earlier shows the "perf top" when addresses
> are created and when they are releasing.

In text form
-------------
Num of addresses	Unpatched (sec)		Patched (sec)
4			1			1
2704			5			5
10404			20			20
23104			45			42
40804			83			74
63504			139			113
