From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/9] network namespaces: playing and debugging
Date: Wed, 16 Aug 2006 09:46:41 -0700
Message-ID: <20060816094641.61190ee9@localhost.localdomain>
References: <20060815182029.A1685@castle.nmd.msu.ru>
	<20060815184843.A2882@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com, serue@us.ibm.com,
	haveblue@us.ibm.com, clg@fr.ibm.com, herbert@13thfloor.at,
	sam@vilain.net, ebiederm@xmission.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, devel@openvz.org,
	alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12778 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932110AbWHPQus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 12:50:48 -0400
To: Andrey Savochkin <saw@sw.ru>
In-Reply-To: <20060815184843.A2882@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Aug 2006 18:48:43 +0400
Andrey Savochkin <saw@sw.ru> wrote:

> Temporary code to play with network namespaces in the simplest way.
> Do
>         exec 7< /proc/net/net_ns
> in your bash shell and you'll get a brand new network namespace.
> There you can, for example, do
>         ip link set lo up
>         ip addr list
>         ip addr add 1.2.3.4 dev lo
>         ping -n 1.2.3.4
> 
> Signed-off-by: Andrey Savochkin <saw@swsoft.com>

NACK, new /proc interfaces are not acceptable.
