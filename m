From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH 3/7 net-2.6.25] [IPV4]: Prohibit assignment of 0.0.0.0
 as interface address.
Date: Fri, 25 Jan 2008 17:13:32 +0300
Message-ID: <4799EE8C.60407@sw.ru>
References: <1201269123-20378-1-git-send-email-den@openvz.org> <1201269123-20378-3-git-send-email-den@openvz.org> <4799EBBE.6080706@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:60460 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753279AbYAYON1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2008 09:13:27 -0500
In-Reply-To: <4799EBBE.6080706@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Denis V. Lunev wrote:
>> I could hardly imagine why sombady needs to assign 0.0.0.0 as an
>> interface
>> address or interface destination address. The kernel will behave in a
>> strage
>> way in several places if this is possible, as ifa_local != 0 is
>> considered
>> as initialized/non-initialized state of the ifa.
> 
> AFAICS, we should be able to set at an interface address to 0.0.0.0, in
> order to remove an IP address from an interface and keep this one up.
> I see two trivial cases:
>  * remove the ipv4 on an interface but continue to use it through ipv6
>  * move ipv4 address from the interface to an attached bridge

For this case there is an IOCTL/netlink "remove IP address".
