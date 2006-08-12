From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: [PATCH,RESEND] smc91x: disable DMA mode on the logicpd pxa270
Date: Sat, 12 Aug 2006 12:27:52 +0300
Message-ID: <20060812092752.GN4745@rhun.haifa.ibm.com>
References: <20060812085506.GA650@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, nico@cam.org,
	mikee@logicpd.com, peterb@logicpd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:22305 "EHLO
	mtagate5.de.ibm.com") by vger.kernel.org with ESMTP
	id S1751380AbWHLJ14 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 05:27:56 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.7/8.13.7) with ESMTP id k7C9RsnM046486
	for <netdev@vger.kernel.org>; Sat, 12 Aug 2006 09:27:54 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7C9VdkE128568
	for <netdev@vger.kernel.org>; Sat, 12 Aug 2006 11:31:39 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7C9RsKb031228
	for <netdev@vger.kernel.org>; Sat, 12 Aug 2006 11:27:54 +0200
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20060812085506.GA650@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 12, 2006 at 10:55:07AM +0200, Lennert Buytenhek wrote:
> Enabling PXA DMA for the smc91x on the logicpd pxa270 produces
> unacceptable interference with the TFT panel, so disable it.

Doesn't this disable it for all users, though? are there any other
users? should this be changed from a #define to a run-time toggle?

Cheers,
Muli
