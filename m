From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v4 0/3] net: reserve ports for applications using fixed port
Date: Tue, 16 Feb 2010 23:22:13 +0200
Message-ID: <201002162322.13101.opurdila@ixiacom.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com> <201002162151.04861.opurdila@ixiacom.com> <m1mxz93pw2.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:2100 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933307Ab0BPV1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 16:27:09 -0500
In-Reply-To: <m1mxz93pw2.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 16 February 2010 22:08:13 you wrote:
> > Something like bellow?
> >
> > # set bits 8080 and 1666
> > $echo 8080 1666-1666 > /proc
> >
> > #reset bit 1666
> > $echo 8080 > /proc
> >
> > #reset whole bitmap
> > $echo > /proc
> 
> Yes. So something like that.
> 
> I think I would use commas instead of spaces as that is more traditional.
> 

OK, I was trying to reuse the existing skip whitespace code :) but if you 
think its cleaner with commas I can do that.

> > Note that this new proc entry will work in conjunction with the existing
> > ip_local_port_range option, so the default bitmap can (and should be)
> > empty.
> 
> Do we want userspace to see this implementation detail? Two data structures
>  doing the almost the same thing could get confusing in a hurry.  It feels
>  like a recipe for changing one and not the other and then running around
>  trying to figure out why the change did not work.
> 

Yes, I believe we want to have reserved_ports contain just those special ports 
that the user wants to reserve. After all we add this entry for this specific 
purpose. 


