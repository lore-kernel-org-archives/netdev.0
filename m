From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: [Bugme-new] [Bug 6495] New: Vlan MTU Fragmentation
Date: Fri, 5 May 2006 19:39:03 -0700
Message-ID: <20060505193903.249feaf8.akpm@osdl.org>
References: <20060504235628.33041b55.akpm@osdl.org>
	<445B75D2.6080702@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	slavon@bigtelecom.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:6040 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751811AbWEFCjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 22:39:19 -0400
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <445B75D2.6080702@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 05 May 2006 08:57:06 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Andrew Morton wrote:
> > 
> > Begin forwarded message:
> > 
> > Date: Thu, 4 May 2006 23:15:56 -0700
> > From: bugme-daemon@bugzilla.kernel.org
> > To: bugme-new@lists.osdl.org
> > Subject: [Bugme-new] [Bug 6495] New: Vlan MTU Fragmentation
> > 
> > 
> > http://bugzilla.kernel.org/show_bug.cgi?id=6495
> > 
> >            Summary: Vlan MTU Fragmentation
> >     Kernel Version: 2.6.16.12
> >             Status: NEW
> >           Severity: normal
> >              Owner: shemminger@osdl.org
> >          Submitter: slavon@bigtelecom.ru
> > 
> > 
> > Steps to reproduce:
> > 
> > ifconfing eth0 mtu 1500
> > ifconfing eth0.100 mtu 1500
> > 
> > ping www.ru -s 2000
> > -- BAD --
> > 
> > ----------------
> > 
> > ifconfing eth0 mtu 1500
> > ifconfing eth0.100 mtu 1496
> > 
> > ping www.ru -s 2000
> > --NORMAL--
> 
> This is almost definately a bug in the ethernet driver.  The driver needs
> to be modified so that it can send/receive pkts that are MTU + 4 bytes for the
> VLAN header.
> 
> We need to know what NIC/driver this user is using...
> 
> Ben
> 

Sorry, I should have added Badalian to Cc:.  He's using 3c905C (3c59x.c,
allegedly maintained by myself).

(Badalian, please use emailed reply-to-all rather than the bugzilla
interface for the remainder of this discussion, thanks).

