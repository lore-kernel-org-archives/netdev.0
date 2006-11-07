From: David Miller <davem@davemloft.net>
Subject: Re: TCP stack sometimes loses ACKs ... or something
Date: Mon, 06 Nov 2006 23:07:55 -0800 (PST)
Message-ID: <20061106.230755.38710002.davem@davemloft.net>
References: <17744.10620.389409.136737@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17847
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1753711AbWKGHHw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 02:07:52 -0500
To: neilb@suse.de
In-Reply-To: <17744.10620.389409.136737@cse.unsw.edu.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Window scaling... there is some intermediate device which is
trying to prevent "out of window" segments from passing through,
but it is not taking the negotiated window scale into account.
So it thinks that segments are outside of the window, when they
are not.
