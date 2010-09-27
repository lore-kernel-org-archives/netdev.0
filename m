From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [Bugme-new] [Bug 18952] New: The mount of SYN retries is not equal
 to /proc/sys/net/ipv4/tcp_syn_retries
Date: Mon, 27 Sep 2010 10:35:41 +0200
Message-ID: <1285576541.27290.1.camel@nexus>
References: <20100922020212.d2aaec57.akpm@linux-foundation.org>
 <20100924.200557.229751150.davem@davemloft.net>
 <201009271007.06705.yuri@itinteg.net>
 <20100927.011046.45906887.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
Cc: yuri@itinteg.net, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:33648 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932655Ab0I0Ifn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 04:35:43 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0L9E00098D7I4P30@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 27 Sep 2010 10:35:42 +0200 (CEST)
Received: from [192.168.0.131] ([unknown] [62.143.253.104])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0L9E00C60D7H6I40@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Mon, 27 Sep 2010 10:35:42 +0200 (CEST)
In-reply-to: <20100927.011046.45906887.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

give me some time, please. I'll take a closer look in the evening.

Regards
 Damian

Am Montag, den 27.09.2010, 01:10 -0700 schrieb David Miller:
> From: Yuri Chislov <yuri@itinteg.net>
> Date: Mon, 27 Sep 2010 10:07:06 +0200
> 
> >   It looks like the behavior changed in 2.6.32. 2.6.32 and up, uses some 
> > calculation instead of a direct definition of the retries number, that makes it 
> > harder to achieve the necessary system behavior.
> > 
> >  The default behavior of the system changed completely
> > (the old default connect timeout was ~ 180 seconds, while the new one is ~21 
> > sec). 
> > 
> > The new behavior invalidates the kernel documentation and tcp man page.
> > 
> > It's not possible to set a connect timeout > 25 sec in the applications while 
> > using the default values in /proc. 
> > 
> > From my view point is regression.
> 
> Agreed, Damian you have to fix this.
> 
> Otherwise I'm reverting all of your Revert Backoff commits.


