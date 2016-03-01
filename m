From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: net-next build failure due to 16e5cc64?
Date: Tue, 1 Mar 2016 13:21:02 -0500
Message-ID: <20160301182102.GR16369@oracle.com>
References: <20160301174233.GO16369@oracle.com>
 <CAM_iQpU8WNCi3GEW0isLsMDWOwzFVkHmDmnqzueLOf7K6P=mAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24065 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbcCASVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 13:21:08 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpU8WNCi3GEW0isLsMDWOwzFVkHmDmnqzueLOf7K6P=mAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/01/16 10:13), Cong Wang wrote:
> > net/sched/sch_mqprio.c: In function `mqprio_init':
> > net/sched/sch_mqprio.c:145: error: unknown field `tc' specified in initializer
    :
> Why not just initialize these fields explicitly? For example,
> 
> +       struct tc_to_netdev tc;
             :
> +       tc.type = TC_SETUP_MQPRIO;

The compiler error is for fields within the union which lacks
both a tag and a union-name.  So I'm not sure how the above will
help.

--Sowmini
