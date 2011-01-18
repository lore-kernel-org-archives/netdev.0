From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 cards intermittantly going offline
Date: Tue, 18 Jan 2011 09:55:58 -0800
Message-ID: <1295373358.8131.4.camel@HP1>
References: <6DD3782C33561D44B47071B09946026405F63853AB@exchange1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Mills, Tony" <tony.mills@jagex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1924 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331Ab1ARSAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 13:00:23 -0500
In-Reply-To: <6DD3782C33561D44B47071B09946026405F63853AB@exchange1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2011-01-18 at 02:54 -0800, Mills, Tony wrote:
> Last night i setup a machine to monitor overnight and at 3:52 this
> morning it became unresponsive. 
> 

When it becomes unresponsive, please send some packets to the NIC (such
as ping) and monitor statistics with ethtool -S.  See if the packets are
being received or discarded.  Also, run tcpdump on the machine to see if
the packets are properly received by the stack.  Thanks.


