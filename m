From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Wed, 31 Dec 2008 22:32:03 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi>
References: <bug-12327-10286@http.bugzilla.kernel.org/>
 <20081229214101.4c4f5ac1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: speedster@haveacry.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39296 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684AbYLaUcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 15:32:05 -0500
In-Reply-To: <20081229214101.4c4f5ac1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Dec 2008, Andrew Morton wrote:

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Mon, 29 Dec 2008 18:52:40 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=12327
> > 
> >            Summary: Intermittent TCP issues with => 2.6.27
> >            Product: Networking
> >            Version: 2.5
> >      KernelVersion: 2.6.27
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: IPV4
> >         AssignedTo: shemminger@linux-foundation.org
> >         ReportedBy: speedster@haveacry.com
> > 
> > 
> > Latest working kernel version: 2.6.26.8
> > Earliest failing kernel version: 2.6.27
> > Distribution: Ubuntu
> > Hardware Environment: amd64, KVM
> > Software Environment:
> > Problem Description:
> > 
> > As reported in LP #296767
> > (https://bugs.launchpad.net/ubuntu/+source/linux/+bug/296767) I am experiencing
> > intermittent TCP issues over a PPP ADSL2+ connection with the only change being
> > an upgrade to 2.6.27.
> > 
> > A number of websites, ping, traceroute work correctly but I simply can't
> > connect to several including:
> > 
> > - store.apple.com
> > - youtube.com
> > - ANZ internet banking (anz.com.au)
> > - MSN messenger
> >
> > I have also tried compiling a generic 2.6.28-rc4 kernel and this still suffers
> > from the same issue, however if I reboot into the previous Ubuntu kernel
> > (2.6.24) or a vanilla 2.6.26 kernel the issue disappears.
> > 
> > Steps to reproduce:
> > 
> > 1. Use a KVM guest as a gateway to a PPP internet connection
> > 2. Boot with kernel <= 2.6.26
> > 3. Observe functioning networking
> > 4. Boot into 2.6.27+
> > 5. Observe broken networking

Can you please describe the full topology (which is connected to where and 
using what, and locations of nats, tun/taps, netfilter things, etc.)... 
There's some contradiction between the ubuntu report description and what 
you're giving here. 

Based on your dumps I find it unlikely that the problem would be in the 
end host tcp but I'll verify the packets field by field still to be 
absolutely sure. I'd guess that either the sent packet or reply gets 
lost somewhere since it never arrives with 2.6.27/2.6.28-rcx.


-- 
 i.
