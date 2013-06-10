From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net v2 03/03] [PATCH] vxlan: fix crash on module removal
Date: Mon, 10 Jun 2013 14:01:14 -0700 (PDT)
Message-ID: <20130610.140114.1116004856133608655.davem@redhat.com>
References: <20130610195822.888424947@vyatta.com>
	<20130610131315.384c5b61@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61084 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753313Ab3FJVBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 17:01:15 -0400
In-Reply-To: <20130610131315.384c5b61@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 10 Jun 2013 13:13:15 -0700

> If vxlan is removed with active vxlan's it would crash because
> rtnl_link_unregister (which calls vxlan_dellink), was invoked
> before unregister_pernet_device (which calls vxlan_stop).
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> ---
> Should goto stable

Applied and queued up for -stable.

Thanks.
