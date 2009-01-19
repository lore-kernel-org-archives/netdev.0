From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] typhoon: replace users of __constant_{endian}
Date: Sun, 18 Jan 2009 22:19:18 -0800
Message-ID: <1232345958.5570.6.camel@brick>
References: <1232066488.11986.5.camel@brick>
	 <1232075884.1502.0.camel@obelisk.thedillows.org>
	 <20090118.220310.122867092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, jeff@garzik.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:35774 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759246AbZASGTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 01:19:22 -0500
Received: by rv-out-0506.google.com with SMTP id k40so2478435rvb.1
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2009 22:19:21 -0800 (PST)
In-Reply-To: <20090118.220310.122867092.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-01-18 at 22:03 -0800, David Miller wrote:
> From: David Dillow <dave@thedillows.org>
> Date: Thu, 15 Jan 2009 22:18:04 -0500
> 
> > On Thu, 2009-01-15 at 16:41 -0800, Harvey Harrison wrote:
> > > The base versions handle constant folding just fine, use them
> > > directly.
> > > 
> > > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > Acked-by: David Dillow <dave@thedillows.org>
> 
> Applied for 2.6.30, thanks everyone.

Dave, I split out typhoon as it had the most uses of the __constant_
versions, the other net drivers have only a handful each, should I
bother splitting that one up, or would you be OK with an omnibus
patch?

Harvey

