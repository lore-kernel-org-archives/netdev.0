From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [PATCH 2.6.19] net/dccp: set safe upper bound for option length
Date: Fri, 22 Sep 2006 11:50:22 -0300
Message-ID: <39e6f6c70609220750i681a28c4lf912c7ccb393cd72@mail.gmail.com>
References: <200609221545.03112@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:10825 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S932556AbWIVOuX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 10:50:23 -0400
Received: by wr-out-0506.google.com with SMTP id i7so497216wra
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 07:50:22 -0700 (PDT)
To: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>
In-Reply-To: <200609221545.03112@strip-the-willow>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/22/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: current upper limit for option length is 128 bytes;
> much less than actually possible. This patch sets a safe upper
> bound on option length of 992, under worst-case assumptions.
>
> This patches against the 2.6.19 tree by David.

Gerrit, could you please use my net-2.6.19? I'm going over the pending
dccp patches backlog and it is possible that this patch now doesn't
applies, haven't checked tho as I'm going out, will check in 20
minutes or so.

Ah, and please keep dccp@vger.kernel.org instead of netdev when the
patch is only dccp specific.

Thanks,

- Arnaldo
