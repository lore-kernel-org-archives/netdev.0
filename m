From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: ip_vs_ftp causing ip_vs oops on module load.
Date: Thu, 19 May 2011 10:52:56 +0200
Message-ID: <201105191052.57291.hans.schillstrom@ericsson.com>
References: <20110518201915.GB20475@redhat.com> <201105190958.56185.hans.schillstrom@ericsson.com> <20110519081706.GE3922@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, Dave Jones <davej@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wensong Zhang <wensong@linuxvirtualserver.org>,
	Hans Schillstrom <hans@schillstrom.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:61363 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932460Ab1ESIw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 04:52:59 -0400
In-Reply-To: <20110519081706.GE3922@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 19 May 2011 10:17:07 Simon Horman wrote:
> On Thu, May 19, 2011 at 09:58:55AM +0200, Hans Schillstrom wrote:
> > On Thursday 19 May 2011 08:33:55 Julian Anastasov wrote:
> > > 
> > > 	Hello,
> > > 
> > [snip]
> > > 
> > > 	One unregister_netdevice_notifier(&ip_vs_dst_notifier);
> > > is missing in ip_vs_control_cleanup for sure.
> > > 
> > Oops, 
> > Should I prepare a patch for that one ?
> 
> Could you test the one I posted?
> (Or send another one if I got it wrong? :-)
> 
Tested,
it works fine :-)
-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
