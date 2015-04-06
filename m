From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: VxLAN system wedge in 4.0.0-rc5+ from davem net-next?
Date: Mon, 6 Apr 2015 16:07:43 -0300
Message-ID: <20150406190743.GA3969@localhost.localdomain>
References: <551F2C20.1060908@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753060AbbDFTHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2015 15:07:46 -0400
Content-Disposition: inline
In-Reply-To: <551F2C20.1060908@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Apr 03, 2015 at 05:11:12PM -0700, Rick Jones wrote:
> Hi -
> 
> I've been messing about with VxLAN with a pair of two socket systems with
> ixgbe-driven NICs (HP 560FLRs for the curious) and have noticed that with a
> kernel from a davem net-next tree I refreshed a couple days ago I can create
> the vlxan link, and ifconfig it, but once I start trying to push packets
> through it the system appears to hang and I have to reset it.
> 
> I went back to checkout v3.19 and tried that kernel and all was happiness
> and joy.  So, I started down the bisect path, but after the first iteration
> I ran into:

That means you could send/receive some packets on it before the hang, right?

  Marcelo
