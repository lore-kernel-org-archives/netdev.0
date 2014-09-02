From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process is
 runnable
Date: Tue, 2 Sep 2014 08:12:22 +0200
Message-ID: <20140902061222.GE5806@worktop.ger.corp.intel.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
 <1408608310-13579-2-git-send-email-jasowang@redhat.com>
 <1408683665.5648.69.camel@marge.simpson.net>
 <20140901093159.GB27892@worktop.ger.corp.intel.com>
 <20140901095219.GD21269@redhat.com>
 <20140901100434.GD27892@worktop.ger.corp.intel.com>
 <54053BC0.6060700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Mike Galbraith <umgwanakikbuti@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60286 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbaIBGMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 02:12:25 -0400
Content-Disposition: inline
In-Reply-To: <54053BC0.6060700@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 02, 2014 at 11:38:40AM +0800, Jason Wang wrote:
> I see, how about just exporting a boolean helper like
> current_can_busy_loop() and take care all of the conditions (pending bhs
> and rcu callbacks, runnable processes) in scheduler code itself?

How is that going to help the cases that are hurt by not spinning for a
packet?
