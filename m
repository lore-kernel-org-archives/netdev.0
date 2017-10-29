From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 0/2] add 'private' and 'vepa' attributes to ipvlan
 modes
Date: Sun, 29 Oct 2017 18:40:14 +0900 (KST)
Message-ID: <20171029.184014.1249935946185114911.davem@davemloft.net>
References: <20171026220906.34686-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        chonggangli@google.com, maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47670 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750915AbdJ2JkS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 05:40:18 -0400
In-Reply-To: <20171026220906.34686-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Thu, 26 Oct 2017 15:09:06 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> IPvlan has always been operating in bridge-mode for its supported modes i.e.
> if the packets are destined to the adjacent neighbor dev, then IPvlan driver
> will switch the packet internally without needing the packets to hit the
> wire or get routed. However, there are situations where this bridge-mode is
> not needed. e.g. two private processes running inside two namespaces which
> are having one IPvlan slave each for its namespace but sharing the master. These
> processes should reach the outside world through the master device but at
> the same time the bridge function should not work. Currently that's not
> possible hence the private attribute for the selected mode comes in play.
> 
> VEPA or 802.1Qbg on the other hand has limited appeal with IPvlan since IPvlan
> uses the mac-address of the lower device. So packets that are destined to 
> the adjacent neighbor slave-dev will have same src and dest mac. When these
> packets reach the external switch/router, they will send you the redirect
> message which the host will have to deal with. Having said that this attribute 
> will have appeal in debugging as IPvlan will not switch / short-circuit 
> packets internally. e.g. using VEPA mode with lower-device in loopback mode
> will avoid some complicated set-ups that use non-local-bind with some route
> jugglery.
> 
> This patch-set implements these attributes for the existing modes that
> IPvlan has. Please see individual patches for their detailed implementation.
> A subsequent ip-utils patch is needed and will be sent soon.

Series applied, thank you.
