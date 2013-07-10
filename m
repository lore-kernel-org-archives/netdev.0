From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH] ip: add support for queue attributes
Date: Wed, 10 Jul 2013 07:23:01 -0700
Message-ID: <51DD6E45.8050003@intel.com>
References: <20130710141312.7205.25585.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	stephen@networkplumber.org, ben@decadent.org.uk,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	therbert@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12726 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754022Ab3GJOXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jul 2013 10:23:18 -0400
In-Reply-To: <20130710141312.7205.25585.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/10/2013 7:13 AM, John Fastabend wrote:
> Test patch to demonstrat and test queue attributes. The 'show'
> formatting could likely be improved.
>
> # ./ip/ip link set dev p3p2 queue 1 rate 1000
> # ./ip/ip link set dev p3p2 queue 5 rate 1000
> # ./ip/ip link show dev p3p2
> 4: p3p2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
>      link/ether 00:1b:21:69:9f:09 brd ff:ff:ff:ff:ff:ff queues:  (1: rate 1000Mbps) (5: rate 1000Mbps)
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>

Oops sorry, demonstrat should be demonstrate and the title should
be 'iproute2' to avoid confusion. Hopefully the context is at least
clear from the patch description.

.John
