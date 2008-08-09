From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Sat, 09 Aug 2008 00:29:56 -0700 (PDT)
Message-ID: <20080809.002956.58270696.davem@davemloft.net>
References: <EA929A9653AAE14F841771FB1DE5A1365F1FBE8B45@rrsmsx501.amr.corp.intel.com>
	<20080802.192639.02765648.davem@davemloft.net>
	<EA929A9653AAE14F841771FB1DE5A1365F1FDE30F1@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36918
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753090AbYHIH3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 03:29:55 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F1FDE30F1@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Date: Fri, 8 Aug 2008 13:38:32 -0600

> I ran into similar panic again. This time on driver reload while
> passing traffic.

Thanks.  I think I know what's going on here but coming up
with a fix will take a little bit longer than usual.
