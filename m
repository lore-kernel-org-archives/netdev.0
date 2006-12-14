From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4][SCTP]: Change adaption -> adaptation as per the
 latest API draft.
Date: Thu, 14 Dec 2006 14:59:29 -0800 (PST)
Message-ID: <20061214.145929.116355686.davem@davemloft.net>
References: <1166060332.4670.37.camel@w-sridhar2.beaverton.ibm.com>
	<20061213.180340.26278674.davem@davemloft.net>
	<1166134936.13207.30.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54155
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751634AbWLNW7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 17:59:42 -0500
To: sri@us.ibm.com
In-Reply-To: <1166134936.13207.30.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 14 Dec 2006 14:22:16 -0800

> On Wed, 2006-12-13 at 18:03 -0800, David Miller wrote:
> > From: Sridhar Samudrala <sri@us.ibm.com>
> > Date: Wed, 13 Dec 2006 17:38:52 -0800
> > 
> > > These parameters are not used by user-space apps. They define the
> > > parameters used by the protocol in SCTP headers that go on wire.
> > 
> > There is no __KERNEL__ ifdef protection for these defines,
> > and the linux/sctp.h header is exported to userspace via
> > include/linux/Kbuild, therefore the interface is exposed to
> > userspace and you cannot break it.
> 
> I didn't know that all the files under include/linux are exported
> to userspace.

Not all of them, only select ones specified in the Kbuild file.

If these structures and defines are meant for kernel-only, or only
partially so, you should either annotate linux/sctp.h with
appropriate __KERNEL__ ifdefs, or remove the header file from
include/linux/Kbuild

You cannot remove the file from Kbuild if it somehow is required
by your SCTP user.h header file, for example.
