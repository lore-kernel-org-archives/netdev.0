From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipvs-next] ipvs: count pre-established TCP states as
 active
Date: Mon, 13 Jun 2016 14:20:07 +0900
Message-ID: <20160613052007.GC11835@verge.net.au>
References: <20160603155650.292BEA0E60@unicorn.suse.cz>
 <alpine.LFD.2.11.1606121825110.2021@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Kubecek <mkubecek@suse.cz>, lvs-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46063 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932181AbcFMFUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 01:20:12 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1606121825110.2021@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 12, 2016 at 06:27:39PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 3 Jun 2016, Michal Kubecek wrote:
> 
> > Some users observed that "least connection" distribution algorithm doesn't
> > handle well bursts of TCP connections from reconnecting clients after
> > a node or network failure.
> > 
> > This is because the algorithm counts active connection as worth 256
> > inactive ones where for TCP, "active" only means TCP connections in
> > ESTABLISHED state. In case of a connection burst, new connections are
> > handled before previous ones have finished the three way handshaking so
> > that all are still counted as "inactive", i.e. cheap ones. The become
> > "active" quickly but at that time, all of them are already assigned to one
> > real server (or few), resulting in highly unbalanced distribution.
> > 
> > Address this by counting the "pre-established" states as "active".
> > 
> > Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon, please apply!

Thanks, done.
