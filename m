From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [RFC] pktgen: set correct max and min in pktgen_setup_inject()
Date: Fri, 6 Jan 2012 09:29:12 -0800
Message-ID: <20120106092912.000015cd@unknown>
References: <20120106131346.GA2491@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39060 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395Ab2AFR3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 12:29:15 -0500
In-Reply-To: <20120106131346.GA2491@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 Jan 2012 05:13:47 -0800
Dan Carpenter <dan.carpenter@oracle.com> wrote:

> In 882716604ec "pktgen: fix multiple queue warning" we added special
> logic to handle the case where ntxq is zero.  It's not clear to me that
> ntxq can actually be zero.  But if it were then we would set
> ->queue_map_min and ->queue_map_max to USHRT_MAX when probably we want
> to set them to zero?

seems fine to me, esp since -1 seems like a bad value there.
