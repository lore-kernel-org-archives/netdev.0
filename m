From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next 00/11] tg3: Bugfixes and 5719 support
Date: Mon, 7 Jun 2010 11:40:38 -0700
Message-ID: <20100607184038.GA12316@mcarlson.broadcom.com>
References: <1275794679-11085-1-git-send-email-mcarlson@broadcom.com>
 <20100606.180029.42789560.davem@davemloft.net>
 <20100607035934.GB11599@mcarlson.broadcom.com>
 <20100607.002805.232920368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2626 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580Ab0FGSlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 14:41:24 -0400
In-Reply-To: <20100607.002805.232920368.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 07, 2010 at 12:28:05AM -0700, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Sun, 6 Jun 2010 20:59:34 -0700
> 
> > On Sun, Jun 06, 2010 at 06:00:29PM -0700, David Miller wrote:
> > The programming manual says this bit prevents a tx state machine lockup
> > due to tx mbuf corruption.  The conditions under which the tx mbufs get
> > corrupted is complicated, but the net effect of this bit is that the
> > RDMA engine acts a little more conservatively.
> 
> That last phrase is a good description and could have been used to
> better name the register bit macro in question.  You're basically
> confirming that you named the register bit too tersely.
> 
> > The problem is that register definitions can change from asic rev to
> > asic rev.
> 
> Frankly, this kind of justification really ticks me off.
> 
> How the heck does that make a difference?  Describe which chip revs
> the register bit is valid for in a comment for crying out loud.
> 
> Document your hardware properly, not selectively or where you see
> it fit to do so.
> 
> It's bad enough that you guys don't publish your hardware specs.
> As a consequence as much knowledge as possible must go into the
> driver sources.  Any piece of information you take away is bad.
> 
> There are tons of chip register bits in this driver already which are
> only valid on certain hardware revs.  In fact, there are many.  Yet
> they are all still there in tg3.h whether they are used by the driver
> or not.  In fact, if I recall correctly, the DMA burst size controls
> are pretty much different on every single rev of the chip.
> 
> Documenting where for which chips a register bit is valid is
> pervasively done elsewhere, and is nothing new.  Your driver and your
> hardware is not special.

Maybe we don't have to take this path.

Our hardware specs are available.  You can find them at:

http://www.broadcom.com/support/ethernet_nic/open_source.php?source=top

The specs for the latest asic revs won't be there yet, but I'm sure
they'll get there.

In light of this, do you still feel we need to take this stance with
the tg3 driver?

