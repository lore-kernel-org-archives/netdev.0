From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [UPDATED] [NET-NEXT PATCH 1/2] pkt_sched: Add multiqueue	scheduler
 support
Date: Tue, 02 Sep 2008 13:53:02 -0700
Message-ID: <48BDA7AE.3080103@intel.com>
References: <20080901210516.GA5931@ami.dom.local> <1220309354.14337.34.camel@ahduyck-laptop> <20080902055411.GA4180@ff.dom.local> <20080902075241.GB4180@ff.dom.local> <80769D7B14936844A23C0C43D9FBCF0F1525E3CA@orsmsx501.amr.corp.intel.com> <20080902200953.GA2544@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:28090 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567AbYIBUxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2008 16:53:06 -0400
In-Reply-To: <20080902200953.GA2544@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Right. But since this doesn't cause this additional blocking I'm not
> sure there is a reason to forbid this. IMHO documenting this could be
> enough, and letting to do this could be useful even for testing. But,
> of course, you are the author, so I don't persist with this.
> 
> Thanks,
> Jarek P.

You are correct in that it doesn't cause any additional blocking, but it 
does break the way that the prio qdisc is supposed to work.  I figure it 
is best to keep all the qdiscs behaving the way they are supposed to 
without my qdisc changing their behavior by acting as a leaf.

Thanks for all the useful input.

Alex



