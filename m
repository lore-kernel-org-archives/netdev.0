From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 1/6] net: Modify all rtnetlink methods to only
 work in the initial namespace (v2)
Date: Mon, 19 Nov 2007 22:33:32 -0800 (PST)
Message-ID: <20071119.223332.164595879.davem@davemloft.net>
References: <20071115155648.GA25428@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, dlezcano@fr.ibm.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34998
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750719AbXKTGdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:33:33 -0500
In-Reply-To: <20071115155648.GA25428@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 15 Nov 2007 18:56:48 +0300

> Before I can enable rtnetlink to work in all network namespaces
> I need to be certain that something won't break.  So this
> patch deliberately disables all of the rtnletlink methods in everything
> except the initial network namespace.  After the methods have been
> audited this extra check can be disabled.
> 
> Changes from v1:
> - added IPv6 addrlabel protection
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, thanks Denis.
