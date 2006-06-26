From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 4/4] Network namespaces: playing and debugging
Date: Mon, 26 Jun 2006 17:04:29 +0200
Message-ID: <449FF77D.3080707@fr.ibm.com>
References: <20060626134945.A28942@castle.nmd.msu.ru> <20060626135250.B28942@castle.nmd.msu.ru> <20060626135427.C28942@castle.nmd.msu.ru> <20060626135537.D28942@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, herbert@13thfloor.at,
	devel@openvz.org, sam@vilain.net, ebiederm@xmission.com,
	viro@ftp.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:37541 "EHLO
	mtagate3.uk.ibm.com") by vger.kernel.org with ESMTP id S932355AbWFZPEb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 11:04:31 -0400
To: Andrey Savochkin <saw@swsoft.com>
In-Reply-To: <20060626135537.D28942@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Savochkin wrote:
> Temporary code to play with network namespaces in the simplest way.
> Do
> 	exec 7< /proc/net/net_ns
> in your bash shell and you'll get a brand new network namespace.
> There you can, for example, do
> 	ip link set lo up
> 	ip addr list
> 	ip addr add 1.2.3.4 dev lo
> 	ping -n 1.2.3.4
> 

Is it possible to setup a network device to communicate with the outside ?
