From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: IPv6 routing/fragmentation panic
Date: Tue, 15 Sep 2015 18:07:58 +0200
Message-ID: <20150915160758.GA27761@unicorn.suse.cz>
References: <1442332400.131189.21.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47111 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754165AbbIOQIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 12:08:00 -0400
Content-Disposition: inline
In-Reply-To: <1442332400.131189.21.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2015 at 04:53:20PM +0100, David Woodhouse wrote:
> I'm not entirely sure how to interpret the above stack trace. Is the
> incoming IPv6 packet being reassembled for netfilter's benefit, then re
> -fragmented for transmission?

Not refragmented. Both the reassembled packet and the original fragments
are kept. Reassembled packet is used for connection tracking and (since
3.13) netfilter rule matching, the original fragments are then forwarded
on (if it passes the rules).

                                                          Michal Kubecek
