From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual network device driver.
Date: Tue, 9 May 2006 12:58:26 +0100
Message-ID: <20060509115826.GA2213@infradead.org>
References: <20060509084945.373541000@sous-sol.org> <20060509085201.446830000@sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:56488 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S932393AbWEIL62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 07:58:28 -0400
To: Chris Wright <chrisw@sous-sol.org>
Content-Disposition: inline
In-Reply-To: <20060509085201.446830000@sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 09, 2006 at 12:00:34AM -0700, Chris Wright wrote:
> The network device frontend driver allows the kernel to access network
> devices exported exported by a virtual machine containing a physical
> network device driver.

Please don't add procfs code to new network drivers.  Especially if it's oopsable
like the code in this driver by simple device renaming.

