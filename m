From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/16] net: Make packet reception network namespace safe
Date: Wed, 12 Sep 2007 04:00:47 -0700 (PDT)
Message-ID: <20070912.040047.70208873.davem@davemloft.net>
References: <m1sl5ovolm.fsf_-_@ebiederm.dsl.xmission.com>
	<m1odgcvoje.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5r0voh4.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:35397
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965213AbXILLAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 07:00:50 -0400
In-Reply-To: <m1k5r0voh4.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:25:43 -0600

> 
> This patch modifies every packet receive function
> registered with dev_add_pack() to drop packets if they
> are not from the initial network namespace.
> 
> This should ensure that the various network stacks do
> not receive packets in a anything but the initial network
> namespace until the code has been converted and is ready
> for them.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24, thanks.
