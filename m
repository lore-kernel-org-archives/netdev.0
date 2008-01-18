From: Dan Nicolaescu <dann@ics.uci.edu>
Subject: Re: [patch] add net_device_stats support to ethtool
Date: Fri, 18 Jan 2008 14:01:06 -0800
Message-ID: <200801182201.m0IM16pw015740@sallyv1.ics.uci.edu>
References: <200801161529.m0GFTfYR005096@sallyv1.ics.uci.edu>
	<479108B4.6030709@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sallyv1.ics.uci.edu ([128.195.1.109]:38950 "EHLO
	sallyv1.ics.uci.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757190AbYARWDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 17:03:07 -0500
In-Reply-To: <479108B4.6030709@garzik.org> (Jeff Garzik's message of "Fri, 18
	Jan 2008 15:14:44 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jeff@garzik.org> writes:

  > Dan Nicolaescu wrote:
  > > Hi,
  > >
  > > I have posted this patch in the past with absolutely no reply.
  > > I would appreciate some sort of feedback of the form interested/not
  > > interested.  Should I just drop it?
  > >
  > > "ethtool -S" only supports devices that have custom code written to
  > > print the stats. 
  > 
  > No -- more specifically, ethtool is for NIC-specific statistics that
  > do not appear elsewhere.
  > 
  > net_device_stats already appear elsewhere, so it's redundant to add it
  > to ethtool.  Just duplicates the same functionality elsewhere.

Then please add to -S entry of the ethtool man page something like:
"Only statistics for devices that do not use the generic stat
infrastructure are printed".
It is rather confusing for users that "ethtool -S" prints stats for some
devices, and nothing for others, and the documentations says nothing
about this.
