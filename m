From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in
 IPoIB
Date: Wed, 08 Aug 2007 21:27:27 -0700 (PDT)
Message-ID: <20070808.212727.60561701.davem@davemloft.net>
References: <20070808.150137.50597736.davem@davemloft.net>
	<OF000FAFC5.C9245715-ON65257332.0016D216-65257332.0017CCB2@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaagaan@gmail.com, general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35507
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751442AbXHIE11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 00:27:27 -0400
In-Reply-To: <OF000FAFC5.C9245715-ON65257332.0016D216-65257332.0017CCB2@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Thu, 9 Aug 2007 09:49:57 +0530

> Patrick had suggested calling dev_hard_start_xmit() instead of
> conditionally calling the new API and to remove the new API
> entirely. The driver determines whether batching is required or
> not depending on (skb==NULL) or not. Would that approach be fine
> with this "single interface" goal ?

It is a valid posibility.

Note that this is similar to how we handle TSO, the driver
sets the feature bit and in its ->hard_start_xmit() it checks
the SKB for the given offload property.
