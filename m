From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: ip_vs_ftp causing ip_vs oops on module load.
Date: Thu, 19 May 2011 09:58:55 +0200
Message-ID: <201105190958.56185.hans.schillstrom@ericsson.com>
References: <20110518201915.GB20475@redhat.com> <20110519032611.GG16688@verge.net.au> <alpine.LFD.2.00.1105190930480.1993@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, Dave Jones <davej@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wensong Zhang <wensong@linuxvirtualserver.org>,
	Hans Schillstrom <hans@schillstrom.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:65176 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932313Ab1ESH67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 03:58:59 -0400
In-Reply-To: <alpine.LFD.2.00.1105190930480.1993@ja.ssi.bg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 19 May 2011 08:33:55 Julian Anastasov wrote:
> 
> 	Hello,
> 
[snip]
> 
> 	One unregister_netdevice_notifier(&ip_vs_dst_notifier);
> is missing in ip_vs_control_cleanup for sure.
> 
Oops, 
Should I prepare a patch for that one ?

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
