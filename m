From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] Interface groups, round two
Date: Thu, 18 Oct 2007 12:20:04 +0200
Message-ID: <47173354.9060301@trash.net>
References: <11927025171404-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33653 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761379AbXJRKU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 06:20:29 -0400
In-Reply-To: <11927025171404-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> Hello,
> 
> Here is the new version of ifgroup patches.
> 
> The interface group value is u_int32_t in net_device which should be enough.
> Previously it was an int.
> 
> Usage:
>    ip link set eth0 group 4
> but currently it cannot be unset, only changed to another value.


The only reason why it can't be set to zero again seems to
be this part from the iproute patch:

+			if (rtnl_ifgroup_a2n(&group, *argv) || group == 0)

Why don't you allow a value of zero?
