From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual network device driver.
Date: Tue, 9 May 2006 16:37:32 -0700
Message-ID: <20060509233732.GH24291@moss.sous-sol.org>
References: <20060509084945.373541000@sous-sol.org> <20060509085201.446830000@sous-sol.org> <20060509115826.GA2213@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:20355 "EHLO
	sous-sol.org") by vger.kernel.org with ESMTP id S932076AbWEIXef
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 19:34:35 -0400
To: Christoph Hellwig <hch@infradead.org>,
	Chris Wright <chrisw@sous-sol.org>,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060509115826.GA2213@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Christoph Hellwig (hch@infradead.org) wrote:
> On Tue, May 09, 2006 at 12:00:34AM -0700, Chris Wright wrote:
> > The network device frontend driver allows the kernel to access network
> > devices exported exported by a virtual machine containing a physical
> > network device driver.
> 
> Please don't add procfs code to new network drivers.  Especially if it's oopsable
> like the code in this driver by simple device renaming.

Agreed, no reason to keep the cruft around.  I thought I had a comment
of the sort in there.

thanks,
-chris
