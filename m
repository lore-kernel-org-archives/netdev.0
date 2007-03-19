From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [LARTC] [BUG?] ip ru flush && RTNETLINK answers: Numerical result out of range
Date: Mon, 19 Mar 2007 16:25:32 +0100
Message-ID: <20070319152532.GL521@postel.suug.ch>
References: <200703190046.47021.luciano@lugmen.org.ar> <45FE2587.3050205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luciano Ruete <luciano@lugmen.org.ar>, lartc@mailman.ds9a.nl,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:35437 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966014AbXCSPZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 11:25:12 -0400
Content-Disposition: inline
In-Reply-To: <45FE2587.3050205@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2007-03-19 06:54
> Thomas, I can't see a clean way to fix this right now that
> doesn't either bloat struct nla_policy or removes FRA_SRC/FRA_DST
> from the policy, could you please look into this? Thanks.

I guess the only way is to remove FRA_SRC/FRA_DST from the policy
and validate it in configure() based on src_len/dst_len.
