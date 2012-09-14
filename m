From: Sami Farin <hvtaifwkbgefbaei@gmail.com>
Subject: Re: [PATCH v2] netfilter: take care of timewait sockets
Date: Fri, 14 Sep 2012 12:30:58 +0300
Message-ID: <20120914093058.ycodkuik6raclaja@m.safari.iki.fi>
References: <20120821134921.behn76vzvhczf3gc@m.safari.iki.fi>
 <20120902122008.jgdhwowbuke6by7h@m.safari.iki.fi>
 <20120902132834.GB7456@breakpoint.cc>
 <1346626385.2563.44.camel@edumazet-glaptop>
 <1346629684.2563.78.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Sami Farin <hvtaifwkbgefbaei@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kponet.fi ([213.145.209.38]:34529 "EHLO smtp.kponet.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758190Ab2INJbA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2012 05:31:00 -0400
Received: from safari.iki.fi (unknown [77.223.43.54])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.kponet.fi (Postfix) with ESMTP id D419ADAD8F
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 12:30:58 +0300 (EEST)
Content-Disposition: inline
In-Reply-To: <1346629684.2563.78.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 03, 2012 at 01:48:04 +0200, Eric Dumazet wrote:
> Sami Farin reported crashes in xt_LOG because it assumes skb->sk is a
> full blown socket.
> 
> But with TCP early demux, we can have skb->sk pointing to a timewait
> socket.
> 
> Same fix is needed in netfnetlink_log

with ip_early_demux=0 and without these patches I did not get panics for
7 days, and with the patches and ip_early_demux=1 it has worked OK for 5 days,
thanks.

-- 
Do what you love because life is too short for anything else.
