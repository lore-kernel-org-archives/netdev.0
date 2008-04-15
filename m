From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NET_SCHED] sch_api: fix qdisc_tree_decrease_qlen() loop
Date: Tue, 15 Apr 2008 05:32:54 +0000
Message-ID: <20080415053253.GA3920@ff.dom.local>
References: <20080413121031.GA5211@ami.dom.local> <20080414202605.GA6164@ami.dom.local> <4803BE84.4040105@trash.net> <20080414.151102.169978802.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, enrico@superclick.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:27323 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783AbYDOFaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 01:30:16 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1858315fgb.17
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2008 22:30:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080414.151102.169978802.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 14, 2008 at 03:11:02PM -0700, David Miller wrote:
...
> > Jarek Poplawski wrote:
...
> > > After this fix qdisc_lookup() is omitted both for ingress and root
> > > parents, but looking for root is only wasting a little time here...

...Actually, there is yet a possibility that somebody uses ffff:
handle for a qdisc (not ingress), which could make here a little
difference, so this place could be improved for this case (even
with something like my earlier debugging patch in this thread,
which BTW could be a safety for maybe some other quirks here),
but it seems it would be better to discourage using this handle
for anything but ingress.

Jarek P.
