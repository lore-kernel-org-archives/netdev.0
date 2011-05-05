From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: use NETIF_F_ALL_TSO for vlan features
Date: Thu, 05 May 2011 10:53:50 -0700 (PDT)
Message-ID: <20110505.105350.183065364.davem@davemloft.net>
References: <4DBA4AB4.5000802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, dm@chelsio.com,
	leedom@chelsio.com, mirqus@gmail.com, bhutchings@solarflare.com
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45532
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754435Ab1EERyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 13:54:22 -0400
In-Reply-To: <4DBA4AB4.5000802@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Fri, 29 Apr 2011 13:20:52 +0800

> 
> As Dimitris Michailidis suggested, use NETIF_F_ALL_TSO for vlan_features,
> which is a mask, but not hw_features. 
> 
> Compile test.
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

I do not understand why we want to advertise a set of ->vlan_features
TSO flags that are different from the flags advertised in ->hw_features.

Why do we want to do this?
