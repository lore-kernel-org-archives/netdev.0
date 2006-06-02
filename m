From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 6638] New: tg3 output freezes on compaq
 nc6000
Date: Fri, 02 Jun 2006 14:23:55 -0700
Message-ID: <1149283436.4067.3.camel@rh4>
References: <200606021240.k52CepX2017904@fire-2.osdl.org>
 <20060602112248.821c9063.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, netdev@vger.kernel.org,
	Klaus.Reichl@alcatel.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:51211 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030341AbWFBXD2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 19:03:28 -0400
To: "Andrew Morton" <akpm@osdl.org>
In-Reply-To: <20060602112248.821c9063.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-02 at 11:22 -0700, Andrew Morton wrote:
> On Fri, 2 Jun 2006 05:40:51 -0700
> bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=6638
> > 
> >            Summary: tg3 output freezes on compaq nc6000
> >     Kernel Version: 2.6.16.19
> >             Status: NEW
> >           Severity: normal
> >              Owner: jgarzik@pobox.com
> >          Submitter: Klaus.Reichl@alcatel.at
> > 
> > 
> > Most recent kernel where this bug did not occur: none
> > Distribution: Debian Sarge with latest kernel
> > Hardware Environment: compaq nc6000
> > Software Environment: 
> > Problem Description: 
> > The output engine of the tg3 driver freezes when generating high load.
> > 
> > `ifconfig' shows incomming packets, however, outgoing counter is not incremented
> > any more.
> > 
Please provide:

1. tg3 probing output during ifconfig up.
2. /proc/interrupts output to see if interrupt counter is increasing
after failure.
3. "ethtool -d eth0 > dump" after the failure.

