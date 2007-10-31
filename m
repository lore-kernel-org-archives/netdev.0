From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/33] Swap over NFS -v14
Date: Tue, 30 Oct 2007 21:37:53 -0700 (PDT)
Message-ID: <20071030.213753.126064697.davem@davemloft.net>
References: <20071030160401.296770000@chello.nl>
	<200710311426.33223.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org,
	trond.myklebust@fys.uio.no
To: nickpiggin@yahoo.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46659
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751943AbXJaEhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 00:37:54 -0400
In-Reply-To: <200710311426.33223.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Wed, 31 Oct 2007 14:26:32 +1100

> Is it really worth all the added complexity of making swap
> over NFS files work, given that you could use a network block
> device instead?

Don't be misled.  Swapping over NFS is just a scarecrow for the
seemingly real impetus behind these changes which is network storage
stuff like iSCSI.
