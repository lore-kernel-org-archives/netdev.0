From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 00/10] Implement batching skb API
Date: Fri, 20 Jul 2007 13:00:25 +0530
Message-ID: <OF37602E5B.BA36F154-ON6525731E.0028A4E9-6525731E.00293CC3@in.ibm.com>
References: <20070720081848.7cc652fb@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se, sri@us.ibm.com,
	tgraf@suug.ch, xma@us.ibm.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:41432 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758376AbXGTHcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 03:32:00 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6K7rsRm209984
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 17:53:55 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6K7Xu7d078884
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 17:34:10 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6K7U8fw006299
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 17:30:11 +1000
In-Reply-To: <20070720081848.7cc652fb@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> wrote on 07/20/2007
12:48:48 PM:

> You may see worse performance with batching in the real world when
> running over WAN's.  Like TSO, batching will generate back to back packet
> trains that are subject to multi-packet synchronized loss. The problem is
that
> intermediate router queues are often close to full, and when a long
string
> of packets arrives back to back only the first ones will get in, the rest
> get dropped.  Normal sends have at least minimal pacing so they are less
> likely do get synchronized drop.

Hi Stephen,

OK. The difference that I could see is that in existing code, the "minimal
pacing" also could lead to (possibly slighly lesser) loss since sends are
quick iterations at the IP layer, while in batching sends are iterative at
the driver layer.

Is it an issue ? Any suggestions ?

Thanks,

- KK

