From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Tue, 14 Oct 2008 21:15:54 +0200
Message-ID: <20081014191554.GA2953@ami.dom.local>
References: <20081014095246.GA10804@ff.dom.local> <48F4CBBA.7070004@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:50046 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbYJNTOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 15:14:47 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1743647fgg.17
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 12:14:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F4CBBA.7070004@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2008 at 09:41:30AM -0700, Alexander Duyck wrote:
...
> I think if anything it seems like you guys actually found the cpu  
> performance issue a while back in the fact that the dev_requeue_skb was  
> calling __netif_schedule when requeuing on a stopped queue.  That is the  
> one piece I would say needs to be changed so that you only call  
> __netif_schedule if the skb is not going to a stopped queue.

BTW, since one of the other "dreams" of killing requeuing failed, I
think this proposal is worth checking, but David was concerned about
some issues with buggy drivers after __netif_schedule() removing.

Jarek P.
