From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 00/21] mlxsw: Support for IPv6 UC router
Date: Fri, 4 Aug 2017 11:50:59 +0300
Message-ID: <20170804085059.GA5383@splinter>
References: <20170803112831.1831-1-jiri@resnulli.us>
 <20170803.153631.974713672754752484.davem@davemloft.net>
 <d6bd0d34-b69f-10c2-059d-a45b1dfae80f@gmail.com>
 <20170803.154124.2094532576602544160.davem@davemloft.net>
 <172d26bc-cb59-c3c7-7ca4-1308f4853e8c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
        netdev@vger.kernel.org, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        kafai@fb.com, hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0081.outbound.protection.outlook.com ([104.47.2.81]:11917
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751290AbdHDIvK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Aug 2017 04:51:10 -0400
Content-Disposition: inline
In-Reply-To: <172d26bc-cb59-c3c7-7ca4-1308f4853e8c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 03, 2017 at 04:54:35PM -0600, David Ahern wrote:
> On 8/3/17 4:41 PM, David Miller wrote:
> > But unlike the percpu flag, don't we want to somehow propagate offload
> > state to the user?
> 
> It's a per nexthop flag. For IPv4 it is tracked in fib_nh.nh_flags.
> Perhaps it is time for rt6_info to have nh_flags as well.

I saw your original mail last night, but was too tired to comment.

I'm looking into reflecting the nexthop status to listeners like what we
did for IPv4 with NH_{ADD,DEL} and can probably incorporate your
suggestion.

Anyway, will make sure RTF_OFFLOAD is removed before the merge window
opens.

Thanks for reviewing David.
