From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Wed, 25 Oct 2006 22:38:38 -0400
Message-ID: <20061026023838.GA6032@havoc.gtf.org>
References: <20061025220406.GA5413@devicescape.com> <453FF357.6060007@trash.net> <45400D86.70406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:31897 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S932222AbWJZCik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 22:38:40 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <45400D86.70406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 26, 2006 at 03:21:10AM +0200, Patrick McHardy wrote:
> Considering that it is possibly and may be desirable to attach a
> different qdisc than the built-in multiband qdisc, it might also
> make sense to split the 80211 specific classification in a seperate
> classifier module to allow simple classification of management traffic
> with other qdiscs.

I've been telling the wireless people this for ages...

	Jeff



