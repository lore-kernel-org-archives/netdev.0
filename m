From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [Bugme-new] [Bug 42132] New: Support BCM5750M in tg3
Date: Thu, 1 Sep 2011 17:06:46 -0700
Message-ID: <20110902000646.GA4910@mcarlson.broadcom.com>
References: <bug-42132-10286@https.bugzilla.kernel.org/>
 <20110901164011.baa9a8b8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"Benjamin Li" <benli@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"stack.box@gmail.com" <stack.box@gmail.com>
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3060 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932714Ab1IBAHM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Sep 2011 20:07:12 -0400
In-Reply-To: <20110901164011.baa9a8b8.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 01, 2011 at 04:40:11PM -0700, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Wed, 31 Aug 2011 18:18:40 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=42132
> > 
> >            Summary: Support BCM5750M in tg3
> >            Product: Drivers
> >            Version: 2.5
> >     Kernel Version: 3.0.3
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Network
> >         AssignedTo: drivers_network@kernel-bugs.osdl.org
> >         ReportedBy: stack.box@gmail.com
> >         Regression: Yes
> > 
> > 
> > I have a notebook (HP TC4400) which has a BCM5750 ethernet card inside. The
> > ouput of lspci is:
> > 
> > 08:00.0 Ethernet controller [0200]: Broadcom Corporation NetXtreme BCM5750M
> > Gigabit Ethernet [14e4:167c]
> > 
> > Commit 67b284d476bcb3d100e946da23d6cf9acfd0465c removed the support for this
> > device.
> > 
> 
> 67b284d476bcb3d100 says "These devices were never released to the public".
> 
> > I wish to have the support for this network card back again. Thanks!
> 
> oops ;)

Really?  All the TC4400 documentation I find says it uses a bcm5753M on a
PCIe bus.  Can you post the full output of 'lspci -vvv -s 08:00.0' ?
