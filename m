From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 driver timeout problems
Date: Mon, 11 Sep 2006 13:14:20 -0700
Message-ID: <1158005660.5436.9.camel@rh4>
References: <6252031.post@talk.nabble.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:23820 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S965026AbWIKUQa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 16:16:30 -0400
To: "sunny12" <johanhen@yahoo.com>
In-Reply-To: <6252031.post@talk.nabble.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-09-11 at 11:18 -0700, sunny12 wrote:

> A restart of the network using /etc/init.d/network restart does the trick
> and the device works again.
> I dont think this is related to the TSO problem reported earlier because I
> believe its disabled by default.
> 
TSO may be on by default on eth0 where you have a 5721.  Check with
ethtool -k eth0.  Turn it off if it is on by doing ethtool -K eth0 tso
off.

