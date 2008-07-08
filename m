From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/9] ipv4: remove static flush_delay variable
Date: Tue, 08 Jul 2008 03:05:59 -0700 (PDT)
Message-ID: <20080708.030559.209246943.davem@davemloft.net>
References: <1215177432-25934-3-git-send-email-den@openvz.org>
	<m1k5fyytid.fsf@frodo.ebiederm.org>
	<1215429974.29879.84.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	ebiederm@xmission.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44414
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751076AbYGHKF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 06:05:59 -0400
In-Reply-To: <1215429974.29879.84.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Mon, 07 Jul 2008 15:26:14 +0400

> On Mon, 2008-07-07 at 01:43 -0700, Eric W. Biederman wrote:
> > "Denis V. Lunev" <den@openvz.org> writes:
> > 
> > > flush delay is used as an external storage for net.ipv4.route.flush sysctl
> > > entry. It is write-only.
> > >
> > > The ctl_table->data for this entry is used once. Fix this case to point
> > > to the stack to remove global variable. Do this to avoid additional
> > > variable on struct net in the next patch.
> > >
> > > Possible race (as it was before) accessing this local variable is removed
> > > using flush_mutex.
> > 
> > FYI.  You can avoid the locking entirely by defining a local struct ctl_table variable
> > on the stack.
> 
> Dave, could you consider the patch attached?

Applied to net-next-2.6, thanks!
