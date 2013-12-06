From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v5 1/2] net: sched: tbf: fix calculation of max_size
Date: Thu, 05 Dec 2013 19:46:27 -0800
Message-ID: <1386301587.30495.215.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386227457-86900-1-git-send-email-yangyingliang@huawei.com>
		 <1386227457-86900-2-git-send-email-yangyingliang@huawei.com>
	 <1386245729.30495.167.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52A1355E.5070301@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, brouer@redhat.com,
	jpirko@redhat.com, jbrouer@redhat.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:51636 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145Ab3LFDq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 22:46:29 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so268114pbb.8
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 19:46:28 -0800 (PST)
In-Reply-To: <52A1355E.5070301@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-06 at 10:24 +0800, Yang Yingliang wrote:
> Hi, Eric
> Thanks for your reviewing and advice!
> 
> On 2013/12/5 20:15, Eric Dumazet wrote:
> > On Thu, 2013-12-05 at 15:10 +0800, Yang Yingliang wrote:
> >>
> >> Suggested-by: Jesper Dangaard Brouer <jbrouer@redhat.com>
> >> Suggested-by: Eric Dumazet <edumazet@google.com>
> > 
> > No, I did not suggest this patch.
> 
> You suggested that
> 
> 	if (qopt->rate.linklayer == TC_LINKLAYER_UNAWARE)
> 	    qdisc_put_rtab(qdisc_get_rtab(&qopt->rate,
> 				          tb[TCA_TBF_RTAB]));
> 
> so I added your suggestion.

OK : The exact meaning of 'Suggested-by: XX' is :

1) the patch idea was given by XX.
2) Then you implemented it.

This is not really the case here : You had the idea of this patch.

I made some feedbacks, you have no special tag to add for that.

Later, if I agree with your next patch set I'll add my own
"Acked-by: ..."

If not (for example I am slow to respond and it got merged), its not a
big deal.

Thanks
