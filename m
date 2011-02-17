From: David Miller <davem@davemloft.net>
Subject: Re: [stable] [PATCH net-2.6/stable] tg3: Restrict phy ioctl access
Date: Wed, 16 Feb 2011 16:10:25 -0800 (PST)
Message-ID: <20110216.161025.59672084.davem@davemloft.net>
References: <20110216230613.GA11053@mcarlson.broadcom.com>
	<20110216.151103.189711682.davem@davemloft.net>
	<20110216235248.GA11108@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, netdev@vger.kernel.org, stable@kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60263
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751067Ab1BQAJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 19:09:49 -0500
In-Reply-To: <20110216235248.GA11108@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 16 Feb 2011 15:52:48 -0800

> On Wed, Feb 16, 2011 at 03:11:03PM -0800, David Miller wrote:
>> From: "Matt Carlson" <mcarlson@broadcom.com>
>> Date: Wed, 16 Feb 2011 15:06:13 -0800
>> 
>> > On Wed, Feb 16, 2011 at 02:39:35PM -0800, Greg KH wrote:
>> >> On Tue, Feb 15, 2011 at 02:51:10PM -0800, Matt Carlson wrote:
>> >> > If management firmware is present and the device is down, the firmware
>> >> > will assume control of the phy.  If a phy access were allowed from the
>> >> > host, it will collide with firmware phy accesses, resulting in
>> >> > unpredictable behavior.  This patch fixes the problem by disallowing phy
>> >> > accesses during the problematic condition.
>> >> > 
>> >> > Upstream commit ID f746a3136a61ae535c5d0b49a9418fa21edc61b5
>> >> 
>> >> There is no such upstream git commit id in Linus's tree.  What am I
>> >> doing wrong here?
>> > 
>> > The commit is in Dave Miller's net-next-2.6 tree.
>> > 
>> 
>> If it wasn't appropriate for net-2.6, it absolutely it not appropriate
>> for -stable.
> 
> net-2.6 was the target tree for the patch.  The stable_kernel_rules.txt
> seemed to suggest that I could just CC stable@kernel.org with the
> commit ID, and Greg would pull it in as the process dictates.  If that
> isn't correct, what is the preferred way to expedite the integration of
> a patch?

You are posting a commit ID for the net-next-2.6 tree, that's what triggered
my response.

Unless it also went into the net-2.6 tree (in which case you should
give Greg the net-2.6 commit ID, which is also what the commit ID must
be in Linus's tree right now), the change is not appropriate for
-stable submission.
