From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 13:30:14 +0300
Message-ID: <20070220103014.GB7237@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <20070220092523.GA6238@2ka.mipt.ru> <200702201104.16200.dada1@cosmosbay.com> <20070220.021209.39159087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: dada1@cosmosbay.com, akepner@sgi.com, linux@horizon.com,
	netdev@vger.kernel.org, bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37286 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932857AbXBTKcO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 05:32:14 -0500
Content-Disposition: inline
In-Reply-To: <20070220.021209.39159087.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 02:12:09AM -0800, David Miller (davem@davemloft.net) wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 20 Feb 2007 11:04:15 +0100
> 
> > Using a jenkin's hash permits a better hash distribution for a litle
> > cpu cost.  I will post later a distribution simulation based on the
> > data gathered from the same real server.
> 
> Actually someone (I think it was Evgeniy in fact) made such
> comparisons and found in his studies that not only does the current
> ehash xor hash function distribute about as well as jenkins, it's
> significantly cheaper to calculate :-)

Yep, it happend to be my tests :)
Jenkins hash was slower and had significant artifacts for some usage
cases ended up with extremely long chain length.
One can find more details at
http://tservice.net.ru/~s0mbre/blog/2006/05/14#2006_05_14
http://tservice.net.ru/~s0mbre/blog/2006/06/01#2006_06_01

-- 
	Evgeniy Polyakov
