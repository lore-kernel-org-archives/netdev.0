From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] veth: Fix carrier detect
Date: Sun, 01 Mar 2009 20:44:45 -0800 (PST)
Message-ID: <20090301.204445.243508134.davem@davemloft.net>
References: <m1ljrtkavi.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757591AbZCBEpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 23:45:04 -0500
In-Reply-To: <m1ljrtkavi.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 25 Feb 2009 21:47:29 -0800

> 
> The current implementation of carrier detect in veth is broken.
> It reports the link is down until both sides of the veth pair
> are administatively up and then forever after it reports link up.
> 
> So fix veth so that it only reports link up when both interfaces
> of the pair are administratively up.
> 
> Signed-off-by: Eric Biederman <ebiederm@aristanetworks.com>

Applied.
