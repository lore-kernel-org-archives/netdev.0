From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/5] s390: use kthread_run in qeth and lcs
Date: Mon, 30 Apr 2007 17:03:29 +0100
Message-ID: <20070430160329.GB27438@infradead.org>
References: <20070430154256.GC23666@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Frank Pavlic <fpavlic@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:39191 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423673AbXD3QDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 12:03:33 -0400
Content-Disposition: inline
In-Reply-To: <20070430154256.GC23666@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 30, 2007 at 05:42:57PM +0200, Frank Pavlic wrote:
> From: Eric Biederman <ebiederm@xmission.com>
> 
> This patch modifies the qeth_recover thread to be started
> with kthread_run not a combination of kernel_thread and
> daemonize.  Resulting in slightly simpler and more maintainable
> code.

NACK, this is Eric's partial conversion which doesn't help much
at all.  In fact it might actually hurt by introducing unpaired
kthread calls.

