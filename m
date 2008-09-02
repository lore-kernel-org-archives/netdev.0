From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [UPDATED] [NET-NEXT PATCH 1/2] pkt_sched: Add multiqueue
	scheduler support
Date: Tue, 2 Sep 2008 07:52:41 +0000
Message-ID: <20080902075241.GB4180@ff.dom.local>
References: <20080901210516.GA5931@ami.dom.local> <1220309354.14337.34.camel@ahduyck-laptop> <20080902055411.GA4180@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, jeff@garzik.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:36788 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbYIBHws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 03:52:48 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1887799fgg.17
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2008 00:52:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080902055411.GA4180@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 02, 2008 at 05:54:11AM +0000, Jarek Poplawski wrote:
...
> OK, but I wonder if it's not enough to treat this as a recommendation?
> Actually, since dequeuing is under the common lock here, the main
> difference seems to be this checking for subqueue_stopped could happen
> a bit earlier,

Hmm.., actually a bit later... Then this should be a bit more exact?!
Anyway, still looks safe to me.

Jarek P.
