From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 16:33:19 +0000
Message-ID: <20071127163319.GA20475@infradead.org>
References: <200711271549.37670.rusty@rustcorp.com.au> <25602.1196178204@lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, Roland Dreier <rdreier@cisco.com>
To: Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58012 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757006AbXK0QdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 11:33:25 -0500
Content-Disposition: inline
In-Reply-To: <25602.1196178204@lwn.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 08:43:24AM -0700, Jonathan Corbet wrote:
> Might the recent discussion on the exporting of sys_open() and
> sys_read() be an example here?  There would appear to be a consensus
> that people should not have used those functions, but they are now
> proving difficult to unexport.

They're not.  The exports aren't used anymore and could just go away
any time.

