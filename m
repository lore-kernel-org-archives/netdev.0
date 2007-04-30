From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: Re: [PATCH 3/5] s390: use kthread_run in qeth and lcs
Date: Mon, 30 Apr 2007 18:30:04 +0200
Message-ID: <20070430163004.GA17951@de.ibm.com>
References: <20070430154256.GC23666@de.ibm.com> <20070430160329.GB27438@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: hch@infradead.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:50317 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946092AbXD3Q1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 12:27:38 -0400
Content-Disposition: inline
In-Reply-To: <20070430160329.GB27438@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 30, 2007 at 05:03:29PM +0100, Christoph Hellwig wrote:
> On Mon, Apr 30, 2007 at 05:42:57PM +0200, Frank Pavlic wrote:
> > From: Eric Biederman <ebiederm@xmission.com>
> > 
> > This patch modifies the qeth_recover thread to be started
> > with kthread_run not a combination of kernel_thread and
> > daemonize.  Resulting in slightly simpler and more maintainable
> > code.
> 
> NACK, this is Eric's partial conversion which doesn't help much
> at all.  In fact it might actually hurt by introducing unpaired
> kthread calls.

Alright Christoph, thanks for clarifying this..

@Jeff, 
I'll send you another set without this one...

Frank
