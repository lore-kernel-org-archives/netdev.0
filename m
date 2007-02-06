From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 7/7] [S390]: Add AF_IUCV socket support
Date: Tue, 6 Feb 2007 09:41:16 +0000
Message-ID: <20070206094116.GA4799@infradead.org>
References: <20070205140243.GH19137@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	jenhunt@us.ibm.com
To: Frank Pavlic <fpavlic@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58903 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbXBFJlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 04:41:21 -0500
Content-Disposition: inline
In-Reply-To: <20070205140243.GH19137@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -#define NPROTO		32		/* should be enough for now..	*/
> +#define NPROTO		33		/* should be enough for now..	*/

You can't simply increase NPROTO, but there should be holes left.
Ask DaveM for a proper allocation.

