From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [Patch 1/5] Network Drop Monitor: Add netlink protocol identifer
Date: Tue, 3 Mar 2009 22:04:57 +0300
Message-ID: <20090303190457.GA8006@ioremap.net>
References: <20090303170014.GB1480@hmsreliant.think-freely.org> <20090303182006.GB29236@ioremap.net> <20090303190054.GI1480@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:34216 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752249AbZCCTE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2009 14:04:59 -0500
Content-Disposition: inline
In-Reply-To: <20090303190054.GI1480@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 03, 2009 at 02:00:54PM -0500, Neil Horman (nhorman@tuxdriver.com) wrote:
> Because this is its own protocol.  I could have used NETLINK_GENERIC I suppose,
> but this is a feature that, if used is going to be commonly built into the
> kernel, I see no need to add an additional step of making userspace search for a
> protocol registered to NETLINK_GENERIC when we dont need to.  In other words,
> why not define my own protocol?

genetlink is alwats built into the kernel, there are access libraries
helpers and there is really no userspace overhead. It was really
specially designed for this kind of the tasks to eliminate netlink
internal structure access and provide simple high-level interface.

-- 
	Evgeniy Polyakov
