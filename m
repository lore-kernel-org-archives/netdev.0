From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v2] geneve: remove use of internal IP header when calling
 IP_ECN_decapsulate
Date: Mon, 21 Sep 2015 10:04:32 -0400
Message-ID: <20150921140432.GB18632@tuxdriver.com>
References: <1442510271-10110-1-git-send-email-linville@tuxdriver.com>
 <1442522094-876-1-git-send-email-linville@tuxdriver.com>
 <20150920.222459.2251924175671848436.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44497 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756325AbbIUOPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 10:15:15 -0400
Content-Disposition: inline
In-Reply-To: <20150920.222459.2251924175671848436.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 20, 2015 at 10:24:59PM -0700, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Thu, 17 Sep 2015 16:34:54 -0400
> 
> > This seems to have been a "thinko".  IP_ECN_decapsulate needs info
> > from both internal and external headers.
> > 
> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> > ---
> > v2 -- ensure the collect_md path still calls IP_ECN_decapsulate
> 
> Judging by the discussion on this patch, I expect that this will
> be respun to make the TX path match what we'll be doing in the RX
> path here.

Yup -- planning to do that this morning!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
