From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS] Don't panic on creating the namespace's loopback
Date: Mon, 15 Oct 2007 12:55:47 -0700 (PDT)
Message-ID: <20071015.125547.109996155.davem@davemloft.net>
References: <47133F91.4030209@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, dlezcano@fr.ibm.com, netdev@vger.kernel.org,
	devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46174
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933305AbXJOTzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 15:55:43 -0400
In-Reply-To: <47133F91.4030209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 15 Oct 2007 14:23:13 +0400

> When the loopback device is failed to initialize inside the new 
> namespaces, panic() is called. Do not do it when the namespace 
> in question is not the init_net.
> 
> Plus cleanup the error path a bit.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Fair enough, applied.
