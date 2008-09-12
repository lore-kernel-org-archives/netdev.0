From: "Alexander Duyck" <alexander.duyck@gmail.com>
Subject: Re: [NET-NEXT PATCH 2/3][UPDATED] pkt_sched: Add multiqueue scheduler support
Date: Thu, 11 Sep 2008 21:42:38 -0700
Message-ID: <5f2db9d90809112142s5745ff5dn480f378f04aeb6a5@mail.gmail.com>
References: <20080912030733.6982.49986.stgit@jtkirshe-mobile.jf.intel.com>
	 <20080912030750.6982.26892.stgit@jtkirshe-mobile.jf.intel.com>
	 <20080911.201940.04283963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	alexander.h.duyck@intel.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.180]:19841 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbYILEmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 00:42:39 -0400
Received: by el-out-1112.google.com with SMTP id z25so339873ele.1
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 21:42:38 -0700 (PDT)
In-Reply-To: <20080911.201940.04283963.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2008 at 8:19 PM, David Miller <davem@davemloft.net> wrote:
> I'm more and more agreeing with Jarek that the root-only restriction
> is rediculious.
>
> What if I want to do PRIO multiqueue for certain classes of traffic?
>
> If I want to shoot myself in the foot trying to use a setup like that,
> this thing damn well better let me.  You don't unilaterally know better
> than the user.

I will submit an additional patch in the next day or so to pull the
root-only requirement.
