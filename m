From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters
 defrag per netns
Date: Wed, 4 Jan 2012 18:40:35 +0100
Message-ID: <20120104174035.GB3489@1984>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com>
 <201201041118.18552.hans.schillstrom@ericsson.com>
 <alpine.LNX.2.01.1201041216010.2645@frira.zrqbmnf.qr>
 <201201041248.36881.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55395 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745Ab2ADRkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 12:40:37 -0500
Content-Disposition: inline
In-Reply-To: <201201041248.36881.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2012 at 12:48:35PM +0100, Hans Schillstrom wrote:
> I like that idea, an "early" table at prio -500 with PREROUTING.
> There is also a need for a new flag "--allfrags"
> i.e. all fragments needs to be sorted out and sent to same dest for defrag.
> 
> ex.
> iptables -t early -A PREROUTING -i eth0 --allfrags -j NOTRACK

New tables add too much overhead. We have discussed this before with
Patrick.

Since this still remains specific to your needs, I think you can
remove nf_conntrack module in your setup.

I don't come with one sane setup that may want selectively defragment
some traffic yes and other not.

Am I missing anything else?
