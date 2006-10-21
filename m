From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] netpoll: rework skb transmit queue
Date: Fri, 20 Oct 2006 23:38:50 -0700 (PDT)
Message-ID: <20061020.233850.02297930.davem@davemloft.net>
References: <20061020.125226.59656580.davem@davemloft.net>
	<20061020132532.65a3e655@dxpl.pdx.osdl.net>
	<20061021050016.GD21948@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:13805
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751752AbWJUGis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Oct 2006 02:38:48 -0400
To: davej@redhat.com
In-Reply-To: <20061021050016.GD21948@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Sat, 21 Oct 2006 01:00:16 -0400

> Practically no-one cared about it, so it bit-rotted really fast
> after we shipped RHEL4.  That, along with the focus shifting to
> making kdump work seemed to kill it off over the last 12 months.

Then we can truly kill off the ->drop() callback as part
of Stephen's patches.

Stephen, I'll review your new set over the weekend.
