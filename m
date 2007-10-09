From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS] Make ifindex generation per-namespace
Date: Tue, 09 Oct 2007 13:12:32 -0700 (PDT)
Message-ID: <20071009.131232.39157518.davem@davemloft.net>
References: <470B71CD.3000706@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, ebiederm@xmission.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54940
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753444AbXJIUMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 16:12:32 -0400
In-Reply-To: <470B71CD.3000706@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 09 Oct 2007 16:19:25 +0400

> Currently indexes for netdevices come sequentially one by
> one, and the same stays true even for devices that are 
> created for namespaces.
> 
> Side effects of this are:
>  * lo device has not 1 index in a namespace. This may break
>    some userspace that relies on it (and AFAIR something
>    really broke in OpenVZ VEs without this);
>  * after some time namespaces will have devices with indexes
>    like 1000000 os similar. This might be confusing for a
>    human (tools will not mind).
> 
> So move the (currently "global" and static) ifindex variable
> on the struct net, making the indexes allocation look more
> like on a standalone machine.
> 
> Moreover - when we have indexes intersect between namespaces,
> we may catch more BUGs in the future related to "wrong device 
> was found for a given index".
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Based upon Eric's and other's comments, I'm holding off on
this for now.
