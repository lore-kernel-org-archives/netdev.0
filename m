From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: net-next build failure due to 16e5cc64?
Date: Tue, 1 Mar 2016 14:09:17 -0500
Message-ID: <20160301190917.GU16369@oracle.com>
References: <20160301174233.GO16369@oracle.com>
 <CAM_iQpU8WNCi3GEW0isLsMDWOwzFVkHmDmnqzueLOf7K6P=mAg@mail.gmail.com>
 <20160301182102.GR16369@oracle.com>
 <CAM_iQpXwd9fQqEh1o56fVqoxUYC5ctY9wqjkAA7UeGru+T8bjw@mail.gmail.com>
 <20160301184119.GS16369@oracle.com>
 <CAM_iQpXDo5Lh+MF7yds3vDyn7D-aqKH3-9kmVYZ924QkAw=imA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22410 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646AbcCATJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 14:09:23 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpXDo5Lh+MF7yds3vDyn7D-aqKH3-9kmVYZ924QkAw=imA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/01/16 10:51), Cong Wang wrote:
> --- a/net/sched/sch_mqprio.c
> +++ b/net/sched/sch_mqprio.c
> @@ -142,7 +142,7 @@ static int mqprio_init(struct Qdisc *sch, struct
> nlattr *opt)
>          */
>         if (qopt->hw) {
>                 struct tc_to_netdev tc = {.type = TC_SETUP_MQPRIO,
> -                                         .tc = qopt->num_tc};
> +                                         {.tc = qopt->num_tc} };
> 

this fix works.

The first suggestion had no effect (needs changes to a lot of files
I suspect).

BTW, I remain surprised that no one else has noticed this. It did not
take me any effort to reproduce it on an x86.

--Sowmini
