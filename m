From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH v1] iproute2: add IFLA_TC support to 'ip link'
Date: Wed, 1 Dec 2010 10:38:02 -0800
Message-ID: <20101201103802.11464029@nehalam>
References: <20101201182758.3297.34345.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@infradead.org,
	eric.dumazet@gmail.com, davem@davemloft.net
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33433 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755489Ab0LASiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 13:38:04 -0500
In-Reply-To: <20101201182758.3297.34345.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Dec 2010 10:27:58 -0800
John Fastabend <john.r.fastabend@intel.com> wrote:

> Add support to return IFLA_TC qos settings to the 'ip link'
> command. The following sets the number of traffic classes
> supported in HW and builds a priority map.
> 
> #ip link set eth3 tc num 8 map 0 1 2 3 4 5 6 7 0 0 0 0 0 0 0 0
> 
> With the output from 'ip link' showing maps for interfaces with
> the ability to use HW traffic classes.
> 
> #ip link show
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
>     link/loopback 00:00:00:00:00:00 brd00:00:00:00:00:00
> 2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
>     link/ether 00:30:48:f0:fc:88 brdff:ff:ff:ff:ff:ff
> 3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
>     link/ether 00:30:48:f0:fc:89 brdff:ff:ff:ff:ff:ff
> 6: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN qlen 1000
>     link/ether 00:1b:21:55:23:58 brdff:ff:ff:ff:ff:ff
>     tc 0:8
> 7: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
>     link/ether 00:1b:21:55:23:59 brdff:ff:ff:ff:ff:ff
>     tc 8:8 map: { 0 1 2 3 4 5 6 7 0 0 0 0 0 0 0 0 }
>     txqs: (0:8) (8:16) (16:24) (24:32) (32:40) (40:48) (48:56) (56:64)
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Ok. but will not be applied until after 2.6.38 (when kernel support
is upstream).


-- 
