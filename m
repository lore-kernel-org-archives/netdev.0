From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.18-rc4-mm[1,2,3] -- Network card not getting assigned an
 "eth" device name
Date: Tue, 29 Aug 2006 02:26:35 -0700 (PDT)
Message-ID: <20060829.022635.08324656.davem@davemloft.net>
References: <20060828120328.ae734de0.akpm@osdl.org>
	<20060828.132717.57158097.davem@davemloft.net>
	<a44ae5cd0608290143m3ad300eej5b325270c9d57b66@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, dcbw@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jeremy@goop.org, rml@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59589
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932228AbWH2J1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 05:27:07 -0400
To: miles.lane@gmail.com
In-Reply-To: <a44ae5cd0608290143m3ad300eej5b325270c9d57b66@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Miles Lane" <miles.lane@gmail.com>
Date: Tue, 29 Aug 2006 01:43:48 -0700

> Then, when I testing running NetworkManager.bak, I got:
> 
> [NetworkManager.:6078]: Changing netdevice name from [eth1] to [`$,3u=(B$,3u=(B]
> [NetworkManager.:6078]: Changing netdevice name from [eth0] to [`$,3u=(B$,3u=(B]

Someone who can debug NetworkManager with gdb or similar needs
to step through it and figure out why it wants to use this
crazy garbage string as the name.
