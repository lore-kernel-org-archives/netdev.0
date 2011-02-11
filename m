From: Chris Friesen <chris.friesen@genband.com>
Subject: any way to reset all marked connections when using CONNMARK?
Date: Fri, 11 Feb 2011 15:24:55 -0600
Message-ID: <4D55A927.7060703@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og119.obsmtp.com ([64.18.2.16]:50079 "EHLO
	exprod7og119.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932175Ab1BKVZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 16:25:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

We've got a scenario where we want to use CONNMARK to mark connections
that have passed a large number of rules in order to allow packets from
those connections to skip rules in the future (for performance reasons).

However, when we add new rules we want to ensure that all the
connections need to pass the new rules as well.

It has been proposed to add a custom patch to clear the mark for all
marked connections--is there a better way of doing this?

I thought maybe we could use the CONNMARK as a generation count and
bumping it up each time a rule is added.  This would require updating
the bypass rule each time we modify the other rules though.  If there
are better options I'd like to hear them.

Thanks,
Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
