From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net-next 0/2] ppp: implement x-netns support
Date: Fri, 14 Aug 2015 10:51:31 +0200
Message-ID: <20150814085131.GD2825@alphalink.fr>
References: <cover.1439471390.git.g.nault@alphalink.fr>
 <20150813.212004.553374390201687089.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60422 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753327AbbHNIvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 04:51:41 -0400
Content-Disposition: inline
In-Reply-To: <20150813.212004.553374390201687089.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 13, 2015 at 09:20:04PM -0700, David Miller wrote:
> From: Guillaume Nault <g.nault@alphalink.fr>
> Date: Thu, 13 Aug 2015 15:28:02 +0200
> 
> > This series allows PPP devices to reside in a different netns from the
> > PPP unit/channels. Packets only cross netns boundaries when they're
> > transmitted between the net_device and the PPP unit (units and channels
> > always remain in their creation namespace).
> > So only PPP units need to handle cross namespace operations. Channels
> > and lower layer protocols aren't affected.
> > 
> > Patch #1 is a bug fix for an existing namespace deletion bug and has
> > been separetly sent to net.
> > Patch #2 is the actual x-netns implementation.
> 
> Patch #1 needs to be respun with the change I requested.
> 
Ok, done.

> And this is not the way to submit things that have dependencies
> upon bug fixes.
> 
Will do. I was actually unsure about how to handle this case.

Thanks.
