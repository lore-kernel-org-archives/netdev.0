From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH 1/2] net-next-2.6: SYN retransmits: Rename threshold
 variable
Date: Fri, 01 Oct 2010 07:22:25 +0200
Message-ID: <1285910545.6212.3.camel@nexus>
References: <1285703144.7187.4.camel@nexus>
 <20100930.172337.220062330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:41548 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751233Ab0JAFW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 01:22:27 -0400
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0L9L005DXIXEKID0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Fri, 01 Oct 2010 07:22:26 +0200 (CEST)
Received: from [192.168.0.131] ([unknown] [95.222.128.132])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0L9L000B9IXEI320@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Fri, 01 Oct 2010 07:22:26 +0200 (CEST)
In-reply-to: <20100930.172337.220062330.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, den 30.09.2010, 17:23 -0700 schrieb David Miller:
> Damian please don't do things like this.


No problem. It was just for preventing the merge conflict Stephen
experienced, as I've seen that parameters have changed in net-next-2.6
already.

Damian

> When we make a change in net-2.6, that change is going to propagate into
> net-next-2.6 the next time I do a merge.
> 
> And in this case here, the addition of the "syn_set" boolean argument to
> retransmits_timed_out() will happen at that point.
> 
> So if anything, you should build on top of the bug fix we put into
> net-2.6 instead of duplicating the change.
> 
> Adding the same change in two different ways to net-2.6 and net-next-2.6
> makes the merge a pain in the neck for me and just makes things look
> real confusing.
> 
> I'm not applying these two patches, please ask me to merge net-2.6 into
> net-next-2.6 and this way you can code them relative to that.
> 
> Thanks!


