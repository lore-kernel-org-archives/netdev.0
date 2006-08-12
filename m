From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.18-rc3-mm2 (+ hotfixes): GPF related to skge on suspend
Date: Sat, 12 Aug 2006 21:32:15 +0200
Message-ID: <200608122132.15289.rjw@sisk.pl>
References: <200608121207.42268.rjw@sisk.pl> <200608121913.01139.rjw@sisk.pl> <20060812181603.GA31106@edgar.underground.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:62863 "EHLO ogre.sisk.pl")
	by vger.kernel.org with ESMTP id S932584AbWHLTgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 15:36:08 -0400
To: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
In-Reply-To: <20060812181603.GA31106@edgar.underground.se.axis.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 12 August 2006 20:16, Edgar E. Iglesias wrote:
> On Sat, Aug 12, 2006 at 07:13:01PM +0200, Rafael J. Wysocki wrote:
> > Apparently it doesn't.
> 
> Hi, could you try and see if this helps?

With the patch I can't reproduce the problem.  I sometimes get the error
messages from the interrupt handler, but then it doesn't blow up in
skge_poll(), so I think the patch helps.

Thanks,
Rafael
