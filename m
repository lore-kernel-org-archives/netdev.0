From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in IPoIB
Date: Thu, 23 Aug 2007 08:13:20 +0530
Message-ID: <OF0CF9546C.CC582BA6-ON65257340.000ECF21-65257340.000EF44C@in.ibm.com>
References: <20070822.021440.123973929.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: gaagaan@gmail.com, general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:50270 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbXHWCm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 22:42:27 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l7N2kCjR206908
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 12:46:12 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7N2gLU83793138
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 12:42:21 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7N2gJnT021529
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 12:42:21 +1000
In-Reply-To: <20070822.021440.123973929.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote on 08/22/2007 02:44:40 PM:

> From: Krishna Kumar2 <krkumar2@in.ibm.com>
> Date: Wed, 22 Aug 2007 12:33:04 +0530
>
> > Does turning off batching solve that problem? What I mean by that is:
> > batching can be disabled if a TSO device is worse for some cases.
>
> This new batching stuff isn't going to be enabled or disabled
> on a per-device basis just to get "parity" with how things are
> now.
>
> It should be enabled by default, and give at least as good
> performance as what can be obtained right now.

That was how it was in earlier revisions. In revision4 I coded it so
that it is enabled only if explicitly set by the user. I can revert
that change.

> Otherwise it's a clear regression.

Definitely. For drivers that support it, it should not reduce performance.

Thanks,

- KK

