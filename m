From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH/RFC] ipv6: fib: Drop cached routes with dead neighbours on fib GC
Date: Fri, 11 Jan 2013 15:01:19 +0100
Message-ID: <20130111140119.GC8436@order.stressinduktion.org>
References: <1357753459-12872-1-git-send-email-roland@kernel.org> <20130111134058.GB8436@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Roland Dreier <roland@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49411 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409Ab3AKOBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 09:01:21 -0500
Content-Disposition: inline
In-Reply-To: <20130111134058.GB8436@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2013 at 02:40:58PM +0100, Hannes Frederic Sowa wrote:
> On Wed, Jan 09, 2013 at 09:44:19AM -0800, Roland Dreier wrote:
> > From: Roland Dreier <roland@purestorage.com>
> > 
> > This patch is as much bug report as it is a proposal to merge this
> > specific patch.  The problem is definitely real; we hit it in a
> > situation where we have two systems connected back-to-back with two
> > bonded links between them, one system reboots, and the other system
> > gets NETDEV_CHANGEADDR.  This patch definitely fixes that case for us,
> > but I'm not sure it's the right place to fix this, or if it covers all
> > the cases where this could happen.  Anyway...
> 
> Great analysis, thanks!
> 
> There is bug report which indicates a fix to this problem could
> also solve some other corner cases regarding neighbour discovery:
> https://bugzilla.kernel.org/show_bug.cgi?id=42991

The report I meant was actually not referred in this bug report:
http://article.gmane.org/gmane.linux.network/224832

ENETDOWN was also observed via bridges.
