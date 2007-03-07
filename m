From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm audit hook misplaced in pfkey_delete and
 xfrm_del_sa
Date: Wed, 07 Mar 2007 15:44:24 -0800 (PST)
Message-ID: <20070307.154424.55724478.davem@davemloft.net>
References: <1172866536.31047.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jmorris@namei.org, vyekkirala@trustedcs.com,
	cxzhang@watson.ibm.com, sds@tycho.nsa.gov
To: eparis@parisplace.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37515
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965753AbXCGXoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 18:44:25 -0500
In-Reply-To: <1172866536.31047.32.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Paris <eparis@parisplace.org>
Date: Fri, 02 Mar 2007 15:15:36 -0500

> Inside pfkey_delete and xfrm_del_sa the audit hooks were not called if
> there was any permission/security failures in attempting to do the del
> operation (such as permission denied from security_xfrm_state_delete).
> This patch moves the audit hook to the exit path such that all failures
> (and successes) will actually get audited.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

Also applied, thanks a lot Eric.
