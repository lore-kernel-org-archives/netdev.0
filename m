From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/3] net/sched: cls_flower: Classify packet in
 ip tunnels
Date: Mon, 22 Aug 2016 10:17:01 -0700
Message-ID: <20160822171700.GA7722@ast-mbp.thefacebook.com>
References: <20160822143834.32422-1-amir@vadai.me>
 <20160822143834.32422-3-amir@vadai.me>
 <20160822190523.684a12e7@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amir Vadai <amir@vadai.me>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34589 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932428AbcHVRcY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 13:32:24 -0400
Received: by mail-pa0-f67.google.com with SMTP id hh10so8437417pac.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 10:32:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160822190523.684a12e7@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 07:05:23PM +0200, Jiri Benc wrote:
> On Mon, 22 Aug 2016 17:38:33 +0300, Amir Vadai wrote:
> > +	if (tb[TCA_FLOWER_KEY_ENC_IPV6_SRC] ||
> > +	    tb[TCA_FLOWER_KEY_ENC_IPV6_DST])
> > +		return -ENOTSUPP;
> 
> Please add also support for IPv6. We've had enough of half-implemented
> stuff in tunneling and we need to really treat IPv6 as a first class
> citizen. There should be no IPv4 only submissions anymore.

+1
As IPv6 only shop we cannot stress enough importance of supporting IPv6
from day one for any new features.
