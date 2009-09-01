From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: H.245v10+ support in nf_conntrack_h323?
Date: Tue, 1 Sep 2009 11:02:30 +0100
Message-ID: <20090901100230.GA18651@sirena.org.uk>
References: <20090901092910.GC11354@urbino.open.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jing Min Zhao <zhaojingmin@users.sourceforge.net>,
	netdev@vger.kernel.org
To: Andreas Jaggi <aj@open.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:40939 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbZIAKCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 06:02:30 -0400
Content-Disposition: inline
In-Reply-To: <20090901092910.GC11354@urbino.open.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2009 at 11:29:10AM +0200, Andreas Jaggi wrote:

> The videoconferencing devices use version 10 of the H.245 protocol,
> but nf_conntrack_h323 supports version 7 (according to the comments in
> include/linux/nf_conntrack_h323.h).

> Are there any plans to include support for version 10 (or higher) of
> H.245 in nf_conntrack_h323?

I'd be surprised if the H.245 version were the source of your problems
here - the new protocol versions are backwards compatible and I don't
remember any changes in any of the stuff that's relevant for firewall
transit.
