From: Simon Horman <horms@verge.net.au>
Subject: Re: ip_vs_ftp causing ip_vs oops on module load.
Date: Thu, 19 May 2011 17:17:07 +0900
Message-ID: <20110519081706.GE3922@verge.net.au>
References: <20110518201915.GB20475@redhat.com>
 <20110519032611.GG16688@verge.net.au>
 <alpine.LFD.2.00.1105190930480.1993@ja.ssi.bg>
 <201105190958.56185.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Anastasov <ja@ssi.bg>, Dave Jones <davej@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wensong Zhang <wensong@linuxvirtualserver.org>,
	Hans Schillstrom <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:52624 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756655Ab1ESIRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 04:17:11 -0400
Content-Disposition: inline
In-Reply-To: <201105190958.56185.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2011 at 09:58:55AM +0200, Hans Schillstrom wrote:
> On Thursday 19 May 2011 08:33:55 Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> [snip]
> > 
> > 	One unregister_netdevice_notifier(&ip_vs_dst_notifier);
> > is missing in ip_vs_control_cleanup for sure.
> > 
> Oops, 
> Should I prepare a patch for that one ?

Could you test the one I posted?
(Or send another one if I got it wrong? :-)
