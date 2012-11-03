From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Query regarding pushing a patch series against net-next tree
Date: Sat, 3 Nov 2012 12:54:03 +0100
Message-ID: <20121103115403.GB4539@electric-eye.fr.zoreil.com>
References: <5094CC60.20907@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Steve Wise <swise@opengridcomputing.com>,
	kumar Sanghvi <kumaras@chelsio.com>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitrios Michailidis <dm@chelsio.com>
To: Vipul Pandya <vipul@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50567 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932075Ab2KCMQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 08:16:16 -0400
Content-Disposition: inline
In-Reply-To: <5094CC60.20907@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vipul Pandya <vipul@chelsio.com> :
[...]
> Can you please suggest how should we proceed for submitting this patch
> series?

- Answer #1
  You rework the fix against -net so that it can be fed into -stable asap
  (your customers use -stable or derivative kernels, don't they ?). You
  rework the feature part against your modified -net vs -net-next merge
  and you carry it until -net gets merged.

- Answer #2
  You wait until David merges -net into -net-next again.

If you don't read netdev regularly (!), you should read
http://marc.info/?l=linux-netdev&m=135170163622882&w=2

-- 
Ueimor
