From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Sun, 25 Nov 2007 21:58:08 -0800
Message-ID: <adalk8lsg3z.fsf@cisco.com>
References: <20071122343.446909000@suse.de>
	<200711231129.25982.rusty@rustcorp.com.au> <adaprxyrrv0.fsf@cisco.com>
	<200711261225.44415.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:59586 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbXKZF6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 00:58:14 -0500
In-Reply-To: <200711261225.44415.rusty@rustcorp.com.au> (Rusty Russell's message of "Mon, 26 Nov 2007 12:25:44 +1100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > I agree that we shouldn't make things too hard for out-of-tree
 > > modules, but I disagree with your first statement: there clearly is a
 > > large class of symbols that are used by multiple modules but which are
 > > not generically useful -- they are only useful by a certain small class
 > > of modules.
 > 
 > If it is so clear, you should be able to easily provide examples?

Sure -- Andi's example of symbols required only by TCP congestion
modules; the SCSI internals that Christoph wants to mark; the symbols
exported by my mlx4_core driver (which I admit are currently only used
by the mlx4_ib driver, but which will also be used by at least the
ethernet NIC driver for the same hardware).  I thought this was
already covered repeatedly in the thread and indeed in Andi's code so
there was no need to repeat it...
