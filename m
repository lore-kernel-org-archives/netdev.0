From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Tue, 13 Oct 2009 17:05:16 -0500
Message-ID: <20091013220516.GA9879@auslistsprd01.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091013150839.GD32107@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com> <20091013195117.GA3778@kroah.com> <5DDAB7BA7BDB58439DD0EED0B8E9A3AE02E8277A@ausx3mpc102.aus.amer.dell.com> <20091013201931.GA4622@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jordan_Hargrave@Dell.com, Narendra_K@Dell.com, dannf@hp.com,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Charles_Rose@Dell.com
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:7755 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934451AbZJMWFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 18:05:55 -0400
Content-Disposition: inline
In-Reply-To: <20091013201931.GA4622@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2009 at 01:19:31PM -0700, Greg KH wrote:
> On Tue, Oct 13, 2009 at 03:00:59PM -0500, Jordan_Hargrave@Dell.com wrote:
> > We have developed a mapping library that will convert the
> > user-friendly symlink names to the kernel names necessary for socket
> > ioctls.  All network tools that normally take ethX as argument have
> > been modified to use this mapping library.  Usually it's just a
> > one-line addition when parsing the command line arguments.
> 
> Either I missed this in the first message in this thread, or this was
> never stated before, but that is nice.  Where is this library,

It was not noted in the initial patch post, but I did note it
immediately thereafter.

 Let me also note that we are prepared to have userspace consumers of
 this new character device node.
 
 http://linux.dell.com/wiki/index.php/Oss/libnetdevname
 
 notes how the kernel patch will interact with udev, describes the new
 library helper function in libnetdevname, and has patches for
 net-tools, iproute2, and ethtool to make use of the helper function.
 
 As has been noted here, MAC addresses are not necessarily unique to an
 interface.  As such, we are not proposing a net/by-mac/* symlink to
 /dev/netdev/*.


> and will it be accepted by the upstream tool maintainers?

Unknown, we haven't proposed it to any yet as it's irrelevant until
there is general acceptance of the approach (kernel or otherwise).  I
figured we'd start with the kernel discussion, and show how it could
be used.

-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
