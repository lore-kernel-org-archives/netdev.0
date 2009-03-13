From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] ixgbe: fix multiple unicast address support
Date: Fri, 13 Mar 2009 13:41:14 -0700 (PDT)
Message-ID: <20090313.134114.192508054.davem@davemloft.net>
References: <20090311020024.22904.48769.stgit@lost.foo-projects.org>
	<9929d2390903102035t7d551aband3b8e793033f9c95@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	christopher.leech@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53767
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751549AbZCMUl2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 16:41:28 -0400
In-Reply-To: <9929d2390903102035t7d551aband3b8e793033f9c95@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 10 Mar 2009 20:35:28 -0700

> On Tue, Mar 10, 2009 at 7:00 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Chris Leech <christopher.leech@intel.com>
> >
> > Multiple unicast address support appears to have been broken with t=
he
> > change to support net_device_ops. =A0This a regression from 2.6.28 =
to 2.6.29.
> >
> > I'm not 100% on whether ndo_set_multicast_list can be NULL after th=
is
> > or not. =A0If ndo_set_rx_mode is set everything _should_ be using i=
t.
> >
> > Signed-off-by: Chris Leech <christopher.leech@intel.com>
> > Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
 ..
>      I know that it is very late in the rc cycle, so I understand if
> this change cannot make it into 2.6.29.  If it is possible, we would
> like to see this 1 line change make 2.6.29.

Ok, since you asked nicely :-)
