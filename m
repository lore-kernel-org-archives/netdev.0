From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Sun, 25 Nov 2007 12:29:39 -0800
Message-ID: <adaprxyrrv0.fsf@cisco.com>
References: <20071122343.446909000@suse.de>
	<200711221456.22297.rusty@rustcorp.com.au>
	<200711221246.23994.ak@suse.de>
	<200711231129.25982.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:21121 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756023AbXKYU3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2007 15:29:40 -0500
In-Reply-To: <200711231129.25982.rusty@rustcorp.com.au> (Rusty Russell's message of "Fri, 23 Nov 2007 11:29:25 +1100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Yes, and if a symbol is already used by multiple modules, it's generically 
 > useful.  And if so, why restrict it to in-tree modules?

I agree that we shouldn't make things too hard for out-of-tree
modules, but I disagree with your first statement: there clearly is a
large class of symbols that are used by multiple modules but which are
not generically useful -- they are only useful by a certain small class
of modules.

 - R.
