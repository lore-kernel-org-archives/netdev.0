From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/3] net/sched: cls_flower: Classify packet in
 ip tunnels
Date: Mon, 22 Aug 2016 19:05:23 +0200
Message-ID: <20160822190523.684a12e7@griffin>
References: <20160822143834.32422-1-amir@vadai.me>
        <20160822143834.32422-3-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40518 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753243AbcHVRF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 13:05:28 -0400
In-Reply-To: <20160822143834.32422-3-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Aug 2016 17:38:33 +0300, Amir Vadai wrote:
> +	if (tb[TCA_FLOWER_KEY_ENC_IPV6_SRC] ||
> +	    tb[TCA_FLOWER_KEY_ENC_IPV6_DST])
> +		return -ENOTSUPP;

Please add also support for IPv6. We've had enough of half-implemented
stuff in tunneling and we need to really treat IPv6 as a first class
citizen. There should be no IPv4 only submissions anymore.

Thanks,

 Jiri
