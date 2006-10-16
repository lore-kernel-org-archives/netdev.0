From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.18-mm2 boot failure on x86-64
Date: Mon, 16 Oct 2006 16:58:14 -0700
Message-ID: <20061016165814.13b99e5e.akpm@osdl.org>
References: <200610052105.00359.ak@suse.de>
	<1160080954.29690.44.camel@flooterbu>
	<200610052250.55146.ak@suse.de>
	<1160101394.29690.48.camel@flooterbu>
	<20061006143312.GB9881@skynet.ie>
	<20061006153629.GA19756@in.ibm.com>
	<20061006171105.GC9881@skynet.ie>
	<1160157830.29690.66.camel@flooterbu>
	<20061006200436.GG19756@in.ibm.com>
	<Pine.LNX.4.64.0610091049390.30765@skynet.skynet.ie>
	<20061016181613.GA30090@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Steve Fox <drfickle@us.ibm.com>, Andi Kleen <ak@suse.de>,
	Badari Pulavarty <pbadari@us.ibm.com>,
	Martin Bligh <mbligh@mbligh.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	kmannth@us.ibm.com, Andy Whitcroft <apw@shadowen.org>,
	Adrian Bunk <bunk@stusta.de>, Mel Gorman <mel@csn.ul.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:59588 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422953AbWJQABw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 20:01:52 -0400
To: vgoyal@in.ibm.com
In-Reply-To: <20061016181613.GA30090@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Oct 2006 14:16:13 -0400
Vivek Goyal <vgoyal@in.ibm.com> wrote:

> 
> Can you please have a look at the attached patch

Looks like a fine patch to me, although it could benefit from a comment
explaining why all those PAGE_ALIGN()s are in there.

> and include it in -mm.

Does it fix a patch in -mm or is it needed in mainline?


