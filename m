From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] net: add tracepoints to socket api
Date: Tue, 27 Jan 2009 12:18:57 -0500
Message-ID: <20090127171857.GB14429@infradead.org>
References: <20090126195930.GA28208@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:38570 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755806AbZA0RS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 12:18:59 -0500
Content-Disposition: inline
In-Reply-To: <20090126195930.GA28208@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2009 at 02:59:30PM -0500, Neil Horman wrote:
> Hey all-
> 	I've been working for a bit with the various tracepoints that have been
> developed in the lttng tree.  The infrastructure is available in the main line
> kernel.  All thats missing are the tracepoints themselves.  While some seem to
> be contentious for various reasons, most seem benign, and can be rather usefull,
> so I was thinking we could start importing Some for the net stack.  Heres a
> patch for the top level socket api tracepoints.  If these are acceptable, I'll
> begin porting over the rest for the remainder of the network stack.   This patch
> applies cleanly against the net-next tree.

Do we now have lttng in linux-next?  Otherwise these trace point would
be useless there without more patching.

