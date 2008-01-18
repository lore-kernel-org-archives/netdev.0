From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] add net_device_stats support to ethtool
Date: Fri, 18 Jan 2008 15:14:44 -0500
Message-ID: <479108B4.6030709@garzik.org>
References: <200801161529.m0GFTfYR005096@sallyv1.ics.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Nicolaescu <dann@ics.uci.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43675 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755390AbYARUOq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 15:14:46 -0500
In-Reply-To: <200801161529.m0GFTfYR005096@sallyv1.ics.uci.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Nicolaescu wrote:
> Hi,
> 
> I have posted this patch in the past with absolutely no reply.
> I would appreciate some sort of feedback of the form 
> interested/not interested.  Should I just drop it?
> 
> "ethtool -S" only supports devices that have custom code written to
> print the stats. 

No -- more specifically, ethtool is for NIC-specific statistics that do 
not appear elsewhere.

net_device_stats already appear elsewhere, so it's redundant to add it 
to ethtool.  Just duplicates the same functionality elsewhere.

	Jeff



