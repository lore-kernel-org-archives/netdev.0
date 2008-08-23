From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] icmp: icmp_sk() should not use smp_processor_id()
 in preemptible code
Date: Sat, 23 Aug 2008 04:45:06 -0700 (PDT)
Message-ID: <20080823.044506.185007231.davem@davemloft.net>
References: <20080821122040.GA2497@x200.localdomain>
	<1219413273-14281-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, adobriyan@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58094
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751563AbYHWLpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 07:45:08 -0400
In-Reply-To: <1219413273-14281-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 22 Aug 2008 17:54:33 +0400

> Pass namespace into icmp_xmit_lock, obtain socket inside and return
> it as a result for caller.
 ...
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks Denis!
