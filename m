From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: RE: [PATCH 1/2 - rev2] qdisc_restart - readability changes plus onebug fix.
Date: Tue, 19 Jun 2007 09:05:28 +0530
Message-ID: <OF1879284F.48E1D196-ON652572FF.00137810-652572FF.0013BA3A@in.ibm.com>
References: <D5C1322C3E673F459512FB59E0DDC329030D56EB@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, hadi@cyberus.ca, herbert@gondor.apana.org.au,
	kaber@trash.net, kumarkr@linux.vnet.ibm.com,
	netdev@vger.kernel.org, tgraf@suug.ch
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:57284 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760653AbXFSDxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 23:53:30 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5J4Ak33284184
	for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 14:15:08 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5J3d4av112044
	for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 13:39:07 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5J3ZVa4024471
	for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 13:35:32 +1000
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329030D56EB@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Peter for testing out. I forgot to mention that I had also ran a 64
process
netperf (tcp & udp) on 2--CPU SMP systems without any issues.

Dave, does it make sense to add this to 2.6.23 ? Herbert and Peter had
earlier reviewed
Patch 2/2 and said they were OK with it.

thanks,

- KK


netdev-owner@vger.kernel.org wrote on 06/18/2007 11:21:46 PM:

> > -----Original Message-----
> > From: Krishna Kumar [mailto:kumarkr@linux.vnet.ibm.com]
> > Sent: Sunday, June 17, 2007 9:51 PM
> > To: davem@davemloft.net
> > Cc: hadi@cyberus.ca; herbert@gondor.apana.org.au; Waskiewicz
> > Jr, Peter P; tgraf@suug.ch; kaber@trash.net; netdev@vger.kernel.org
> > Subject: [PATCH 1/2 - rev2] qdisc_restart - readability
> > changes plus onebug fix.
> >
> > New changes :
> >
> > - Incorporated Peter Waskiewicz's comments.
> > - Re-added back one warning message (on driver returning wrong value).
>
> I've run these patches last night and this morning without issue.  I see
> no issues with these updated patches from my testing.
>
> Thanks,
> -PJ Waskiewicz
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

