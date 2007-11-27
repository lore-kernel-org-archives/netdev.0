From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 16:58:28 +0100
Message-ID: <20071127155828.GF24223@one.firstfloor.org>
References: <200711271549.37670.rusty@rustcorp.com.au> <25602.1196178204@lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, Roland Dreier <rdreier@cisco.com>
To: Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:58251 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759271AbXK0P63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 10:58:29 -0500
Content-Disposition: inline
In-Reply-To: <25602.1196178204@lwn.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 08:43:24AM -0700, Jonathan Corbet wrote:
> Rusty said:
> 
> > Well, introduce an EXPORT_SYMBOL_INTERNAL().  It's a lot less code.  But you'd 
> > still need to show that people are having trouble knowing what APIs to use.
> 
> Might the recent discussion on the exporting of sys_open() and
> sys_read() be an example here?  There would appear to be a consensus
> that people should not have used those functions, but they are now
> proving difficult to unexport.

That is a good example yes.

> Perhaps the best use of the namespace stuff might be for *future*
> exports which are needed to help make the mainline kernel fully modular,
> but which are not meant to be part of a more widely-used API?

Not sure about future only, but yes that is its intention.
Thanks for putting it clearly.

-Andi
