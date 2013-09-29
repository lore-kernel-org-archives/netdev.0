From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] tcp: TSQ can use a dynamic limit
Date: Sun, 29 Sep 2013 08:41:29 -0700
Message-ID: <CAM_iQpV7600r+j2JR0ZA1GtrbECSMUTN=VcY51tHu+RFCpz0Dg@mail.gmail.com>
References: <20130906101635.GI14104@zion.uk.xensource.com>
	<1378472268.31445.15.camel@edumazet-glaptop>
	<522A049A.7000105@citrix.com>
	<1378486840.31445.36.camel@edumazet-glaptop>
	<1378574494.26319.14.camel@edumazet-glaptop>
	<522E4080.2050802@citrix.com>
	<1378763815.26319.39.camel@edumazet-glaptop>
	<loom.20130921T045654-573@post.gmane.org>
	<20130921150327.GA9078@zion.uk.xensource.com>
	<CAM_iQpUCGA+ifOUoyh4EuPz5sn8wUgtoD=_5dpRMuYV5aqEdxQ@mail.gmail.com>
	<1379861902.3431.12.camel@edumazet-glaptop>
	<1380277734.30872.25.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Wei Liu <wei.liu2@citrix.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:52772 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675Ab3I2Pla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 11:41:30 -0400
Received: by mail-oa0-f41.google.com with SMTP id n10so3320377oag.28
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 08:41:29 -0700 (PDT)
In-Reply-To: <1380277734.30872.25.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 3:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Additional change : skb->destructor should be set to tcp_wfree().
>
> A future patch (for linux 3.13+) might remove tcp_limit_output_bytes

Yeah, now it is only used in tcp_xmit_size_goal()...
