From: Andi Kleen <ak@muc.de>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops callsites to make them patchable
Date: 20 Mar 2007 20:28:18 +0100
Message-ID: <20070320192818.GA87860@muc.de>
References: <20070318120814.GA45869@muc.de> <1174272469.11680.23.camel@localhost.localdomain> <m1648xxf93.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org> <1174348905.11680.54.camel@localhost.localdomain> <45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org> <Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org> <m1mz27sy82.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Zachary Amsden <zach@vmware.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, anthony@codemonkey.ws, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colin.muc.de ([193.149.48.1]:1200 "EHLO mail.muc.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934047AbXCTT2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 15:28:20 -0400
Date: Tue, 20 Mar 2007 20:28:18 +0100
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> But I was throwing that out as a long-term thing. I'm not claiming it's 
> trivial, but it should be doable.

One thing I was pondering was to replace the expensive popfs with

bt  $IF,(%rsp) 
jnc 1f 
sti
1: 

But would be mostly a P4 optimization again and I'm not 100% sure it is
worth it.

-Andi

