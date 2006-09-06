From: Daniel Drake <dsd@gentoo.org>
Subject: [RFT] sky2 vs iptables
Date: Tue, 05 Sep 2006 21:36:24 -0400
Message-ID: <44FE2618.3010705@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mcclung@nebrwesleyan.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp131.iad.emailsrvr.com ([207.97.245.131]:7646 "EHLO
	smtp141.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S932210AbWIFBiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 21:38:05 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

There's a strange sky2 bug on the Gentoo bugzilla:
http://bugs.gentoo.org/show_bug.cgi?id=136508

sky2 seems to work OK, but breaks as soon as the iptables ruleset is 
loaded. Nothing can be pinged, etc.

Can someone try and reproduce this? The iptables rule script has been 
uploaded here:
http://bugs.gentoo.org/attachment.cgi?id=95694&action=view

The very last command in that file is the one which produces an error 
and stops everything working:

	iptables: Unknown error 18446744073709551615

Apparently a sky2 null deref has also been seen at this point, although 
I don't have further details on that.

Thanks!
Daniel
