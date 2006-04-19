From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][RFC] Security marking
Date: Wed, 19 Apr 2006 15:49:13 -0700 (PDT)
Message-ID: <20060419.154913.133865982.davem@davemloft.net>
References: <Pine.LNX.4.64.0604160012500.16600@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, sds@tycho.nsa.gov,
	chrisw@sous-sol.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27595
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751279AbWDSWtN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 18:49:13 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0604160012500.16600@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Sun, 16 Apr 2006 01:10:50 -0400 (EDT)

> So, I propose to introduce a secmark field (per the patch below), which is 
> only present when enabled as a sub-feature of LSM.  That is, it does not 
> have any effect at all for the default kernel.  As an integer field, it 
> also does not require the kind of lifecycle management assoicated with 
> security blobs, which becomes invasive for skbs.

I have no objections to this at all.  And off-list I've gotten James
to agree to be assigned to try and shrink SKB somehow in the future
which is only fair :-)

