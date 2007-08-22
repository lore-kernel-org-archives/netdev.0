From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in
 IPoIB
Date: Wed, 22 Aug 2007 02:14:40 -0700 (PDT)
Message-ID: <20070822.021440.123973929.davem@davemloft.net>
References: <20070821.212229.82050253.davem@davemloft.net>
	<OF6B96E612.D20F2F6A-ON6525733F.0025E38A-6525733F.0026BBB8@in.ibm.com>
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
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48322
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763175AbXHVJOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 05:14:41 -0400
In-Reply-To: <OF6B96E612.D20F2F6A-ON6525733F.0025E38A-6525733F.0026BBB8@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Wed, 22 Aug 2007 12:33:04 +0530

> Does turning off batching solve that problem? What I mean by that is:
> batching can be disabled if a TSO device is worse for some cases.

This new batching stuff isn't going to be enabled or disabled
on a per-device basis just to get "parity" with how things are
now.

It should be enabled by default, and give at least as good
performance as what can be obtained right now.

Otherwise it's a clear regression.
