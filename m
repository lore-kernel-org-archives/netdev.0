From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 03 Dec 2013 09:12:33 -0800
Message-ID: <1386090753.30495.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <529DF340.70602@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:58228 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141Ab3LCRMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 12:12:35 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so21284975pbc.5
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 09:12:35 -0800 (PST)
In-Reply-To: <529DF340.70602@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-03 at 17:05 +0200, Or Gerlitz wrote:

> ----------------------
> 
> ip link add vxlan42 type vxlan id 42 group 239.0.0.42 ttl 10 dev ethN
> ifconfig vxlan42 192.168.42.144/24 up
> 
> brctl addbr br-vx
> ip link set br-vx up
> 
> ifconfig br-vx 192.168.52.144/24 up
> brctl addif br-vx vxlan42
> 
> ip link add type veth

> brctl addif br-vx veth1

Aside question : If I do not have brctl on my host,
how can I use "ip" command to perform this "brctl addif" action ?
