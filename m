From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/3] First pass of cleanups for pskb_expand_head
Date: Sat, 05 May 2012 07:44:31 +0200
Message-ID: <1336196671.3752.490.camel@edumazet-glaptop>
References: <20120505001059.21292.31647.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:57960 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab2EEFof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2012 01:44:35 -0400
Received: by werb10 with SMTP id b10so300154wer.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 22:44:34 -0700 (PDT)
In-Reply-To: <20120505001059.21292.31647.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-04 at 17:26 -0700, Alexander Duyck wrote:
> pull the actual value.
> 
> There are a few more items that I will try to get to next week.  The big one
> is the fact that pskb_expand_head can mess up the truesize since it can
> allocate a new head but never updates the truesize.  I plan on adding a helper
> function for the cases where we are just using it unshare the head so I can
> identify the places where we are actually modifying the size.

In the old days, truesize adjustements were done after
pskb_expand_head() calls. (Mabye because some contexts didnt care of
truesize for ephemeral skbs, not charged to a socket)

So it will be a nice cleanup for sure.
