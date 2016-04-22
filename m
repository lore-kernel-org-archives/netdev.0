From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 0/2] pskb_extract() helper function.
Date: Fri, 22 Apr 2016 19:41:49 -0400
Message-ID: <20160422234149.GD30220@oracle.com>
References: <cover.1461086306.git.sowmini.varadhan@oracle.com>
 <20160422232301.GA1594@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com, davem@davemloft.net,
	eric.dumazet@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23191 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800AbcDVXl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 19:41:59 -0400
Content-Disposition: inline
In-Reply-To: <20160422232301.GA1594@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (04/22/16 20:23), marcelo.leitner@gmail.com wrote:
> My tests results were very similar to what I had without it. Varying to
> better or worse, tending worse.  Thing is, SCTP always works on
> linearized skbs as it can't crawl on fragments, so those clone/trim

sorry to hear that. For RDS-TCP, the rx side does show a noticeable
benefit with rds-stress. To an extent, this is also impacted
by the packet size, and the type of test (for our DB workloads,
we use request-response tests, and the packet size tends to
typically be 8K req, 256 byt responses), so I guess ymmv. 

--Sowmini
