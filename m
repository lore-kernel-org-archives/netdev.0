From: Matt Domsch <matt_domsch@dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 9 Oct 2009 09:51:38 -0500
Message-ID: <20091009145137.GD19218@mock.linuxdev.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com>
Reply-To: Matt Domsch <Matt_Domsch@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	jordan_hargrave@dell.com
To: Narendra K <narendra_k@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:4519 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760824AbZJIOwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 10:52:16 -0400
Content-Disposition: inline
In-Reply-To: <20091009140000.GA18765@mock.linuxdev.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 09, 2009 at 09:00:01AM -0500, Narendra K wrote:
> On Fri, Oct 09, 2009 at 07:12:07PM +0530, K, Narendra wrote:
> > > example udev config:
> > > SUBSYSTEM=="net",
> > SYMLINK+="net/by-mac/$sysfs{ifindex}.$sysfs{address}"
> > 
> > work as well.  But coupling the ifindex to the MAC address like this
> > doesn't work.  (In general, coupling any two unrelated attributes when
> > trying to do persistent names doesn't work.)
> > 
> Attaching the latest patch incorporating review comments.

Thank you Narendra.

Let me also note that we are prepared to have userspace consumers of
this new character device node.

http://linux.dell.com/wiki/index.php/Oss/libnetdevname

notes how the kernel patch will interact with udev, describes the new
library helper function in libnetdevname, and has patches for
net-tools, iproute2, and ethtool to make use of the helper function.

As has been noted here, MAC addresses are not necessarily unique to an
interface.  As such, we are not proposing a net/by-mac/* symlink to
/dev/netdev/*.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
