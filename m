From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 1/1] alx: add a simple AR816x/AR817x device driver
Date: Fri, 21 Jun 2013 22:42:54 +0200
Message-ID: <1371847374.8936.0.camel@jlt4.sipsolutions.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1370899746-14219-1-git-send-email-johannes@sipsolutions.net>
	 <1371518286.3495.60.camel@deadeye.wl.decadent.org.uk>
	 <1371764438.8333.20.camel@jlt4.sipsolutions.net>
	 <1371765508.8771.17.camel@deadeye.wl.decadent.org.uk>
	 <1371766157.8333.25.camel@jlt4.sipsolutions.net>
	 <1371818751.8771.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com, Johannes Stezenbach <js@sig21.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:53195 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945951Ab3FUUm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 16:42:57 -0400
In-Reply-To: <1371818751.8771.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-21 at 13:45 +0100, Ben Hutchings wrote:

> > Ok, I can kick out the 'select NET_CORE' here anyway as MDIO doesn't
> > need it. Or did you want to do a more general cleanup on this, then I'll
> > leave it to you?
> 
> See commit a1606c7dc64d8449676d7e840dd2cd0c4e0a0c57.

Ok, I'll remove it from alx.

> > How would I even test that? Find random devices that have flow control?
> > I don't think I have anything that would be programmable, unless I don't
> > know about it being so :-)
> 
> Most Ethernet controllers seem to support flow control.  Though, in a
> quick test, the e1000e driver on my laptop never seems to turn off Pause
> advertising!

Hah! And how did you determine that? :)

johannes
