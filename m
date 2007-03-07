From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add xfrm policy change auditing to pfkey_spdget
Date: Wed, 07 Mar 2007 15:43:16 -0800 (PST)
Message-ID: <20070307.154316.68038380.davem@davemloft.net>
References: <1172861484.31047.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jmorris@namei.org, vyekkirala@trustedcs.com,
	cxzhang@watson.ibm.com, sds@tycho.nsa.gov
To: eparis@parisplace.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37506
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965751AbXCGXnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 18:43:17 -0500
In-Reply-To: <1172861484.31047.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Paris <eparis@parisplace.org>
Date: Fri, 02 Mar 2007 13:51:24 -0500

> pfkey_spdget neither had an LSM security hook nor auditing for the
> removal of xfrm_policy structs.  The security hook was added when it was
> moved into xfrm_policy_byid instead of the callers to that function by
> my earlier patch and this patch adds the auditing hooks as well.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

Applied.
