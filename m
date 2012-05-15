From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] ipv6: fix incorrect ipsec transport mode fragment
Date: Tue, 15 May 2012 13:48:40 +0200
Message-ID: <20120515114840.GC24733@secunet.com>
References: <20120215104021.GC31660@secunet.com>
 <1336965660-14201-1-git-send-email-gaofeng@cn.fujitsu.com>
 <20120514130528.GA24733@secunet.com>
 <4FB1D11A.4040206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, lw@cn.fujitsu.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52338 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757851Ab2EOLsp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 07:48:45 -0400
Content-Disposition: inline
In-Reply-To: <4FB1D11A.4040206@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 15, 2012 at 11:44:26AM +0800, Gao feng wrote:
> 
> how about add a function pointer append_data to the struct rt6_info?
> so we can just call rt->append_data in ip6_append_data without conside
> witch mode it is.
> 

If you want to use a function pointer, it should go to stuct xfrm_mode.
That's where the IPsec mode dependent functions reside.

A side note, I'll be off for three weeks starting from tomorrow.
I'll have no E-mail access most of the time, so I'll probaply not
respond for the next three weeks.
