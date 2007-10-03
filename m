From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: jumbo frame regression fix
Date: Tue, 2 Oct 2007 21:59:14 -0700
Message-ID: <20071002215914.13d1e8cf@freepuppy.rosehill>
References: <1191372129.26233.12.camel@localhost>
	<20071002180209.47c350a3@freepuppy.rosehill>
	<1191375274.26233.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: pomac@vapor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56760 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751512AbXJCFCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 01:02:04 -0400
In-Reply-To: <1191375274.26233.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 03 Oct 2007 03:34:34 +0200
Ian Kumlien <pomac@vapor.com> wrote:

> On tis, 2007-10-02 at 18:02 -0700, Stephen Hemminger wrote:
> > Remove unneeded check that caused problems with jumbo frame sizes.
> > The check was recently added and is wrong.
> > When using jumbo frames the sky2 driver does fragmentation, so
> > rx_data_size is less than mtu.
> 
> Confirmed working.
> 
> Now running with 9k mtu with no errors, =)
> 
> It also seems that the FIFO bug was the one that affected me before,
> damn odd race that one.

Does the workaround (forced reset work). Ian, you are the first person to
report triggering it.  I haven't found a way to make it happen.
What combination of flow control and speeds are you using?


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
