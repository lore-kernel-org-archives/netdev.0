From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: Dynamically allocate the per cpu counters for
 the loopback device.
Date: Thu, 27 Sep 2007 11:52:00 -0700 (PDT)
Message-ID: <20070927.115200.56183114.davem@davemloft.net>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>
	<20070926.220901.51682476.davem@davemloft.net>
	<m1myv8r1lb.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57373
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755071AbXI0SwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 14:52:00 -0400
In-Reply-To: <m1myv8r1lb.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 27 Sep 2007 01:48:00 -0600

> I'm not doing get_cpu/put_cpu so does the comment make sense
> in relationship to per_cpu_ptr?

It is possible.  But someone would need to go check for
sure.
