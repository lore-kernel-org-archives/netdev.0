From: David Miller <davem@davemloft.net>
Subject: Re: IPV4: Enable IP_ID sequencing for all traffic (inquiring minds
 want to know why its set to zero)
Date: Wed, 16 Jul 2008 13:30:48 -0700 (PDT)
Message-ID: <20080716.133048.201600858.davem@davemloft.net>
References: <OF4F3F2DB0.24836443-ON88257488.0068C9C1-88257488.0068F7AD@us.ibm.com>
	<487E4A6B.6040103@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51827
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754187AbYGPUat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 16:30:49 -0400
In-Reply-To: <487E4A6B.6040103@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 16 Jul 2008 14:22:19 -0500

> Wasnt there a time when we did IP_ID on every packet? Any changelogs from that time?

The current behavior existed way before GIT and BK so this might be
hard to come by.

A quick check shows that 2.2.x does an unconditional iph->id = ip_id_count++
so you can work forwards from there :-)
