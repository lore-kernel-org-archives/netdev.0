From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 2/3] slab: introduce SMP alignment
Date: Thu, 6 Mar 2008 21:26:24 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803062120410.1215@schroedinger.engr.sgi.com>
References: <20080303093529.GB15091@wotan.suse.de>
 <Pine.LNX.4.64.0803031104570.6917@schroedinger.engr.sgi.com>
 <20080303200355.GB8974@wotan.suse.de> <Pine.LNX.4.64.0803031208400.16049@schroedinger.engr.sgi.com>
 <20080303201211.GE8974@wotan.suse.de> <Pine.LNX.4.64.0803031216430.3110@schroedinger.engr.sgi.com>
 <20080303202411.GH8974@wotan.suse.de> <Pine.LNX.4.64.0803031327330.4375@schroedinger.engr.sgi.com>
 <20080307043700.GI21185@wotan.suse.de> <Pine.LNX.4.64.0803062108210.1143@schroedinger.engr.sgi.com>
 <20080307051944.GJ21185@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:33055 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751232AbYCGF0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2008 00:26:42 -0500
In-Reply-To: <20080307051944.GJ21185@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Internode alignment is 4k. If you need an object aligned like that then it 
may be better to go to the page allocator.



