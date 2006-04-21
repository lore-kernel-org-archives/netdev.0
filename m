From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 18:13:02 -0700 (PDT)
Message-ID: <20060420.181302.98895633.davem@davemloft.net>
References: <20060420213305.GK26746@pb15.lixom.net>
	<20060420.172742.132879746.davem@davemloft.net>
	<44482EB5.9030605@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, andrew.grover@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48335
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932095AbWDUBNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 21:13:07 -0400
To: rick.jones2@hp.com
In-Reply-To: <44482EB5.9030605@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 20 Apr 2006 18:00:37 -0700

> Actually, that brings-up a question - presently, and for reasons that 
> are lost to me in the mists of time - netperf will "access" the buffer 
> before it calls recv().  I'm wondering if that should be changed to an 
> access of the buffer after it calls recv()?

Yes, that's what it should do, as this is whan a real
application would do.
