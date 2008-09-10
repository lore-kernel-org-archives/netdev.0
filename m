From: "Ranjit Manomohan" <ranjitm@google.com>
Subject: Re: [PATCH 0/2] Traffic control cgroups subsystem
Date: Wed, 10 Sep 2008 13:44:23 -0700
Message-ID: <166fe7950809101344l7a5e2b7pfba8b2a7c03814a1@mail.gmail.com>
References: <Pine.LNX.4.64.0809101026190.7050@ranjit.corp.google.com>
	 <20080910.132251.73509521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, akpm@linux-foundation.org, lizf@cn.fujitsu.com,
	menage@google.com, tgraf@suug.ch, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:35534 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbYIJUoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 16:44:39 -0400
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id m8AKiVUR014793
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 21:44:32 +0100
Received: from gxk12 (gxk12.prod.google.com [10.202.11.12])
	by spaceape12.eur.corp.google.com with ESMTP id m8AKgGId012922
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 13:44:30 -0700
Received: by gxk12 with SMTP id 12so14602348gxk.10
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 13:44:24 -0700 (PDT)
In-Reply-To: <20080910.132251.73509521.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2008 at 1:22 PM, David Miller <davem@davemloft.net> wrote:
>
> I definitely prefer Thomas Graf's work, this stuff is very ugly
> and way overengineered.
>

Could you be more specific? Thomas' work is almost identical to this
(except that he does not store the cgroup id into the socket which is
a trivial change which has downsides which I have pointed out).

Additionally this approach has only minor modifications to the core
networking stack. What portions do you consider ugly and over
engineered and what alternative implementations would you prefer?
Please see the follow up I have sent to Thomas' proposal about why we
need this design approach to handle the inbound case.

I'd be ok if you accepted either change since  we just want a standard
kernel mechanism to do this.

-Thanks,
Ranjit

> So no, I won't consider for net-next-2.6, sorry.
>
>
