From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH 4/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 20:20:01 -0500
Message-ID: <1289524801.5167.76.camel@dan>
References: <1289524026.5167.68.camel@dan>
	 <20101111.171024.242132239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, kuznet@ms2.inr.ac.ru,
	urs.thuermann@volkswagen.de, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jmorris@namei.org, remi.denis-courmont@nokia.com,
	pekkas@netcore.fi, sri@us.ibm.com, vladislav.yasevich@hp.com,
	tj@kernel.org, eric.dumazet@gmail.com, lizf@cn.fujitsu.com,
	joe@perches.com, shemminger@vyatta.com, hadi@mojatatu.com,
	ebiederm@xmission.com, adobriyan@gmail.com, jpirko@redhat.com,
	johannes.berg@intel.com, daniel.lezcano@free.fr, xemul@openvz.org,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:61837 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658Ab0KLBUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:20:11 -0500
In-Reply-To: <20101111.171024.242132239.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> This will print zero once a socket enters various closing states or
> similar, since the sk->sk_socket is released and turns NULL.
> 
> Thus making the debugging information next to useless.
> 
> I'm still largely against these changes, and will not apply them
> to my tree.

Would you care to offer any suggestions that would both solve the
problem and be acceptable to you?

If not, then you have committed to leaving a permanent easy target for
exploits.  Please think carefully about this.

-Dan

