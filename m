From: Chris Webb <chris@arachsys.com>
Subject: Re: How to use macvtap/macvlan correctly
Date: Sun, 2 Oct 2011 20:46:17 +0100
Message-ID: <20111002194616.GM14562@arachsys.com>
References: <20100826114355.GA455@arachsys.com>
 <20110930084935.GC12879@arachsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: qemu-devel@nongnu.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.arachsys.com ([91.203.57.7]:55852 "EHLO
	alpha.arachsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435Ab1JBTqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2011 15:46:18 -0400
Content-Disposition: inline
In-Reply-To: <20110930084935.GC12879@arachsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Webb <chris@arachsys.com> writes:

> I'm trying to get bridge-mode communication between a macvtap and a host
> macvlan working correctly, but I think I must be doing something wrong as
> the host macvlan and guest macvtap apparently can't communicate. I'm aware
> that the underlying eth0 interface can't communicate with the macvtap, but I
> thought that creating a host macvlan device and configuring that was the
> standard work-around?

This turns out to be a bug in the kernel I'm using, 3.0.4, fixed by this
patch:

  http://patchwork.ozlabs.org/patch/115273/

Cheers,

Chris.
