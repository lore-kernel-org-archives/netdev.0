From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: e100 REGRESSION in 2.6.32
Date: Wed, 16 Dec 2009 14:50:38 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.0912161447260.2643-100000@iolanthe.rowland.org>
References: <alpine.WNT.2.00.0912160938450.5316@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Roger Oksanen <roger.oksanen@cs.helsinki.fi>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:51547 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751899AbZLPTup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 14:50:45 -0500
In-Reply-To: <alpine.WNT.2.00.0912160938450.5316@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Dec 2009, Brandeburg, Jesse wrote:

> copied the netdev mailing list.

Oops.  With all the other CC's I forgot to include netdev.  Shame, 
shame...

>  Alan thanks for the report, I wonder if 
> you can revert 98468efddb101f8a29af974101c17ba513b07be1 and see if that 
> fixes it?

It does indeed.  Thanks for the quick response.

> Roger on the To: line made that change, which may have broken e100 for 
> your system.

It looks simple enough, but obviously something is wrong with it.

Alan Stern

