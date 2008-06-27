From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Fri, 27 Jun 2008 14:01:10 +0400
Message-ID: <20080627100109.GC18179@2ka.mipt.ru>
References: <20080401235609.GA6947@codemonkey.org.uk> <200804022012.58760.nickpiggin@yahoo.com.au> <20080402085437.7d9abf1f.akpm@linux-foundation.org> <200804031622.26973.nickpiggin@yahoo.com.au> <20080402223254.5ac50337.akpm@linux-foundation.org> <20080403085922.GA10874@2ka.mipt.ru> <20080626210624.GA11816@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Dave Jones <davej@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43594 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752755AbYF0KCI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 06:02:08 -0400
Content-Disposition: inline
In-Reply-To: <20080626210624.GA11816@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2008 at 05:06:24PM -0400, Dave Jones (davej@redhat.com) wrote:
> This thread seemed to die out with no resolution..

Please ask to test e1000e driver instead, if it supports given PCI ids.
It has completely rewritten input path which does not suffer from this
kind of problems, so you do not need to care too much about e1000, which
will die sooner or later.

-- 
	Evgeniy Polyakov
