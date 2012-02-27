From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Re: [PATCH, RFC] skge: Fix race in tx path
Date: Mon, 27 Feb 2012 21:52:01 +0100
Message-ID: <20120227205201.GA3863@electric-eye.fr.zoreil.com>
References: <4142816.cJc9u7kBPI@asus> <20120226202710.GA23874@electric-eye.fr.zoreil.com> <3669580.gQc5FCr96Z@asus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jeff@garzik.org>
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39513 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753070Ab2B0UwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Feb 2012 15:52:14 -0500
Content-Disposition: inline
In-Reply-To: <3669580.gQc5FCr96Z@asus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bart Van Assche <bvanassche@acm.org> :
> > With this change it seems possible for skge_tx_done to unmap a buffer
> > before it is sent when the requests for skge_xmit_frame are close enough.
> 
> Thanks for the feedback. Does the patch below look better ? 

Yes.

-- 
Ueimor
